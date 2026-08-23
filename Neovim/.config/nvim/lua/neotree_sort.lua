-- Sort neo-tree siblings by project and package dependencies.
-- This mirrors tyrant-rules: project dependencies are topologically ordered,
-- TypeScript packages use index.*, Python packages use __init__.py, and
-- @module-group members share one layer.
local M = {}

local entry_names = {
    "index.ts",
    "index.tsx",
    "index.mts",
    "index.cts",
    "__init__.py",
}

local cache = {}
local project_cache = {}

local project_config_names = {
    "eslint.config.ts",
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "pyproject.toml",
}

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

local function read_file(path)
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok then
        return nil
    end

    return table.concat(lines, "\n")
end

local function quoted_values(text)
    local values = {}
    for quote, value in text:gmatch("(['\"])(.-)%1") do
        if quote and value ~= "" then
            table.insert(values, value)
        end
    end
    return values
end

local function topological_layers(dependencies, declared_layers)
    local ordered = {}
    local states = {}

    local function visit(layer)
        if states[layer] == "visiting" then
            -- No ordering can put both sides of a cycle before each other.
            return false
        end
        if states[layer] == "visited" then
            return true
        end

        states[layer] = "visiting"
        for _, dependency in ipairs(dependencies[layer] or {}) do
            if dependencies[dependency] and not visit(dependency) then
                return false
            end
        end
        states[layer] = "visited"
        table.insert(ordered, layer)
        return true
    end

    for _, layer in ipairs(declared_layers) do
        if not visit(layer) then
            return nil
        end
    end
    return ordered
end

local function graph_layers(graph_body)
    local dependencies = {}
    local declared_layers = {}
    local cursor = 1

    while true do
        local double_start, double_end, double_name, double_dependencies =
            graph_body:find('"([^"]+)"%s*:%s*(%b[])', cursor)
        local single_start, single_end, single_name, single_dependencies =
            graph_body:find("'([^']+)'%s*:%s*(%b[])", cursor)
        local bare_start, bare_end, bare_name, bare_dependencies =
            graph_body:find("([%a_$][%w_$]*)%s*:%s*(%b[])", cursor)

        local candidates = {}
        local function add_candidate(start_position, end_position, name, array)
            if start_position then
                table.insert(candidates, {
                    array = array,
                    end_position = end_position,
                    name = name,
                    start_position = start_position,
                })
            end
        end
        add_candidate(
            double_start,
            double_end,
            double_name,
            double_dependencies
        )
        add_candidate(
            single_start,
            single_end,
            single_name,
            single_dependencies
        )
        add_candidate(bare_start, bare_end, bare_name, bare_dependencies)

        if #candidates == 0 then
            break
        end
        table.sort(candidates, function(a, b)
            return a.start_position < b.start_position
        end)

        local entry = candidates[1]
        dependencies[entry.name] = quoted_values(entry.array)
        table.insert(declared_layers, entry.name)
        cursor = entry.end_position + 1
    end

    return topological_layers(dependencies, declared_layers)
end

local function eslint_project_layers(text)
    local rule_arguments =
        text:match("enforce%-project%-layer%-dependencies['\"]%s*:%s*(%b[])")
    if not rule_arguments then
        return nil
    end

    local option_prefix = "^%[%s*['\"][^'\"]+['\"]%s*,%s*"
    local legacy_array = rule_arguments:match(option_prefix .. "(%b[])")
    if legacy_array then
        return quoted_values(legacy_array)
    end

    local graph_body = rule_arguments:match(option_prefix .. "(%b{})")
    if not graph_body then
        local graph_name =
            rule_arguments:match(option_prefix .. "([%a_$][%w_$]*)")
        if graph_name then
            graph_body = text:match("const%s+" .. graph_name .. "%s*=%s*(%b{})")
        end
    end

    return graph_body and graph_layers(graph_body) or nil
end

local function pylint_project_layers(text)
    local layer_array = text:match("tyrant[-_]layers%s*=%s*(%b[])")
    return layer_array and quoted_values(layer_array) or nil
end

local function read_project_sort_keys(directory)
    local config_path
    for _, name in ipairs(project_config_names) do
        local candidate = directory .. "/" .. name
        if vim.uv.fs_stat(candidate) then
            config_path = candidate
            break
        end
    end
    if not config_path then
        return nil
    end

    local signature = entry_signature(config_path)
    local cached = project_cache[directory]
    if
        cached
        and cached.config_path == config_path
        and cached.signature == signature
    then
        return cached.sort_keys
    end

    local text = read_file(config_path)
    local layers
    if text then
        if vim.fs.basename(config_path) == "pyproject.toml" then
            layers = pylint_project_layers(text)
        else
            layers = eslint_project_layers(text)
        end
    end

    local present_layers = {}
    for _, name in ipairs(layers or {}) do
        local stat = vim.uv.fs_stat(directory .. "/" .. name)
        if stat then
            table.insert(present_layers, name)
        end
    end

    -- Assign the configured order to the alphabetical slots already occupied
    -- by configured layers. Unlisted siblings consequently never move.
    local alphabetical_slots = vim.deepcopy(present_layers)
    table.sort(alphabetical_slots)
    local sort_keys = {}
    for index, name in ipairs(present_layers) do
        sort_keys[name] = alphabetical_slots[index]
    end

    project_cache[directory] = {
        config_path = config_path,
        signature = signature,
        sort_keys = sort_keys,
    }
    return sort_keys
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
            local doc_line = line:gsub("^%s*/%*+", "")
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
                and prefix:sub(1, #declared_prefix + 1) == declared_prefix .. separator
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

    local project_sort_keys = read_project_sort_keys(a_directory)
    if project_sort_keys then
        local a_name = vim.fs.basename(a.path)
        local b_name = vim.fs.basename(b.path)
        local a_key = project_sort_keys[a_name]
        local b_key = project_sort_keys[b_name]
        if a_key or b_key then
            return default_sort(
                vim.tbl_extend("force", a, {
                    path = a_directory .. "/" .. (a_key or a_name),
                }),
                vim.tbl_extend("force", b, {
                    path = b_directory .. "/" .. (b_key or b_name),
                })
            )
        end
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
