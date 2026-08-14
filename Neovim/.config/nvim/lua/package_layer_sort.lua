-- Sort neo-tree siblings by the package layers declared in their entry file.
-- This mirrors tyrant-rules: TypeScript packages use index.* and Python
-- packages use __init__.py; @module-group members share one layer.
local M = {}

local entry_names = {
    "index.ts",
    "index.tsx",
    "index.mts",
    "index.cts",
    "__init__.py",
}

local cache = {}

local function default_sort(a, b)
    if a.type == b.type then
        return a.path < b.path
    end

    return a.type < b.type
end

local function find_entry(directory)
    for _, name in ipairs(entry_names) do
        local path = directory .. "/" .. name
        if vim.uv.fs_stat(path) then
            return path
        end
    end
end

local function entry_signature(path)
    local stat = vim.uv.fs_stat(path)
    if not stat then
        return "missing"
    end

    return table.concat({
        stat.size,
        stat.mtime.sec,
        stat.mtime.nsec,
    }, ":")
end

local function declared_name(tag_body)
    -- Descriptions start after a whitespace-surrounded dash, as required by
    -- enforce-package-layer-dependencies.
    return vim.trim((tag_body:match("^(.-)%s+%-%s+") or tag_body))
end

local function read_spec(directory)
    local entry = find_entry(directory)
    if not entry then
        return nil
    end

    local signature = entry_signature(entry)
    local cached = cache[directory]
    if cached and cached.entry == entry and cached.signature == signature then
        return cached.spec
    end

    local layers = {}
    local layer = 0
    local ok, lines = pcall(vim.fn.readfile, entry)
    if ok then
        for _, line in ipairs(lines) do
            local doc_line = line
                :gsub("^%s*/%*+", "")
                :gsub("^%s*%* ?", "")
                :gsub("%*/%s*$", "")
                :match("^%s*(.-)%s*$")
            local group = doc_line:match("^@module%-group%s+(.+)")
            local single = doc_line:match("^@module%s+(.+)")
            local body = group or single

            if body then
                layer = layer + 1
                local names = declared_name(body)
                if group then
                    for name in names:gmatch("[^,]+") do
                        layers[vim.trim(name)] = layer
                    end
                elseif names ~= "" then
                    layers[names] = layer
                end
            end
        end
    end

    local spec = {
        entry_name = vim.fs.basename(entry),
        layers = layers,
        max_layer = layer,
    }
    cache[directory] = {
        entry = entry,
        signature = signature,
        spec = spec,
    }
    return spec
end

local function source_prefix(name)
    local typescript_prefix = name:match("^(.*)%.tsx?$")
        or name:match("^(.*)%.mts$")
        or name:match("^(.*)%.cts$")
    if typescript_prefix and not typescript_prefix:match("%.d$") then
        return typescript_prefix, "."
    end

    local python_prefix = name:match("^(.*)%.py$")
    if python_prefix then
        return python_prefix, "_"
    end
end

local function layer_for(name, spec)
    if name == spec.entry_name then
        return spec.max_layer + 1
    end

    -- tyrant-rules treats qualified index source files as entry-layer
    -- siblings, for example index.benchmark.test.ts beside index.ts.
    local entry_prefix, entry_separator = source_prefix(spec.entry_name)
    local prefix, separator = source_prefix(name)
    if
        entry_prefix
        and prefix
        and separator == entry_separator
        and prefix:sub(1, #entry_prefix + 1) == entry_prefix .. separator
    then
        return spec.max_layer + 1
    end

    local exact_layer = spec.layers[name]
    if exact_layer then
        return exact_layer
    end

    -- Qualified sibling files inherit the longest declared source-file
    -- prefix, matching tyrant-rules' optional prefix-inheritance behavior.
    if prefix then
        local inherited_layer
        local longest_match = 0
        for declared, declared_layer in pairs(spec.layers) do
            local declared_prefix, declared_separator = source_prefix(declared)
            if
                declared_prefix
                and separator == declared_separator
                and prefix:sub(1, #declared_prefix + 1)
                    == declared_prefix .. separator
                and #declared_prefix > longest_match
            then
                inherited_layer = declared_layer
                longest_match = #declared_prefix
            end
        end
        if inherited_layer then
            return inherited_layer
        end
    end

    -- A valid package declares every feature module, so remaining siblings
    -- occupy the shared bottom layer. Non-module files stay alphabetized there.
    return 0
end

---@param a table A neo-tree file item.
---@param b table A neo-tree file item.
---@return boolean
function M.sort(a, b)
    -- neo-tree probes custom sorters with minimal synthetic items.
    if type(a.path) ~= "string" or type(b.path) ~= "string" then
        return default_sort(a, b)
    end

    local a_directory = vim.fs.dirname(a.path)
    local b_directory = vim.fs.dirname(b.path)
    if a_directory ~= b_directory then
        return default_sort(a, b)
    end

    local spec = read_spec(a_directory)
    if not spec or spec.max_layer == 0 then
        return default_sort(a, b)
    end

    local a_layer = layer_for(vim.fs.basename(a.path), spec)
    local b_layer = layer_for(vim.fs.basename(b.path), spec)

    if a_layer ~= b_layer then
        return a_layer < b_layer
    end

    return default_sort(a, b)
end

return M
