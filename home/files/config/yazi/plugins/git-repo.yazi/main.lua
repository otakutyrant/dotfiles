local cache = {}
local root_cache = {}
local SUCCESS_TTL = 5
local FAILURE_TTL = 30

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function git_output(path, arguments)
    local pipe = io.popen(
        "git --no-optional-locks -C "
            .. shell_quote(path)
            .. " "
            .. arguments
            .. " 2>/dev/null",
        "r"
    )
    if not pipe then
        return nil
    end

    local output = pipe:read("*a")
    pipe:close()
    return output
end

local function status_for(path)
    local normalized_path = path:gsub("/+$", "")
    local now = os.time()
    local root_entry = root_cache[path]
    local root_ttl = root_entry and root_entry.is_root and SUCCESS_TTL
        or FAILURE_TTL
    if not root_entry or now - root_entry.time >= root_ttl then
        local root = git_output(path, "rev-parse --show-toplevel")
        root = root and root:gsub("%s+$", "") or nil
        root_entry = {
            is_root = root == normalized_path,
            time = now,
        }
        root_cache[path] = root_entry
    end

    if not root_entry.is_root then
        return nil
    end

    local output = git_output(
        path,
        "status --porcelain=v1 --branch --ahead-behind --untracked-files=normal"
    )
    if not output then
        return nil
    end

    local header = output:match("^[^\r\n]+") or ""
    local branch = header:match("^## ([^%.]+)") or "HEAD"
    local ahead = tonumber(header:match("ahead (%d+)")) or 0
    local behind = tonumber(header:match("behind (%d+)")) or 0
    local staged, unstaged, untracked = 0, 0, 0

    for line in output:gmatch("[^\r\n]+") do
        if not line:match("^##") then
            local x, y = line:sub(1, 1), line:sub(2, 2)
            if x == "?" and y == "?" then
                untracked = untracked + 1
            else
                if x ~= " " then
                    staged = staged + 1
                end
                if y ~= " " then
                    unstaged = unstaged + 1
                end
            end
        end
    end

    return {
        branch = branch,
        ahead = ahead,
        behind = behind,
        staged = staged,
        unstaged = unstaged,
        untracked = untracked,
    }
end

local function format_status(status)
    local parts = { " " .. status.branch }
    if status.behind > 0 then
        parts[#parts + 1] = "⇣" .. status.behind
    end
    if status.ahead > 0 then
        parts[#parts + 1] = "⇡" .. status.ahead
    end
    if status.staged > 0 then
        parts[#parts + 1] = "+" .. status.staged
    end
    if status.unstaged > 0 then
        parts[#parts + 1] = "!" .. status.unstaged
    end
    if status.untracked > 0 then
        parts[#parts + 1] = "?" .. status.untracked
    end
    return table.concat(parts, " ")
end

local function setup()
    Linemode:children_add(function(self)
        if not self._file.in_current or not self._file.cha.is_dir then
            return ""
        end

        local path = tostring(self._file.url)
        local now = os.time()
        local entry = cache[path]
        local ttl = entry and entry.status and SUCCESS_TTL or FAILURE_TTL
        if not entry or now - entry.time >= ttl then
            entry = { time = now, status = status_for(path) }
            cache[path] = entry
        end

        return entry.status and ui.Line({ " ", format_status(entry.status) })
            or ""
    end, 1400)
end

return { setup = setup }
