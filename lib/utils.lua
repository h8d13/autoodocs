-- @def:9 Localize `string.*`, `table.*`, and `io.*` functions
-- bypasses metatable and global lookups in the hot loop
local find   = string.find
local sub    = string.sub
local byte   = string.byte
local match  = string.match
local gsub   = string.gsub
local open   = io.open

local M = {}

-- @def:3!n Shell-escape a string for safe interpolation into `io.popen`
-- prevents breakage from paths containing `"`, `$()`, or backticks
function M.shell_quote(s)
    return "'" .. gsub(s, "'", "'\\''") .. "'"
end

-- @run:6 Strip leading whitespace, returns original if unchanged
function M.trim_lead(s)
    local i = 1
    while byte(s, i) == 32 or byte(s, i) == 9 do i = i + 1 end
    if i == 1 then return s end
    return sub(s, i)
end

-- @run:6 Strip trailing whitespace, returns original if unchanged
function M.trim_trail(s)
    local i = #s
    while i > 0 and (byte(s, i) == 32 or byte(s, i) == 9) do i = i - 1 end
    if i == #s then return s end
    return sub(s, 1, i)
end

-- @run:3 Trim both ends via `trim_lead` and `trim_trail`
function M.trim(s)
    return M.trim_trail(M.trim_lead(s))
end

-- @def:12 Map file extension to fenced code block language
M.ext_map = {
    sh="sh", bash="sh", py="python",
    js="javascript", mjs="javascript", cjs="javascript",
    ts="typescript", mts="typescript", cts="typescript",
    jsx="jsx", tsx="tsx", rb="ruby", go="go", rs="rust",
    c="c", h="c", cpp="cpp", hpp="cpp", cc="cpp", cxx="cpp",
    java="java", cs="csharp", swift="swift", kt="kotlin", kts="kotlin",
    lua="lua", sql="sql", html="html", htm="html", css="css", xml="xml",
    yaml="yaml", yml="yaml", toml="toml", json="json",
    php="php", pl="perl", pm="perl", zig="zig",
    hs="haskell", ex="elixir", exs="elixir", erl="erlang",
}

-- @def:4 Map shebang interpreters to fenced code block language
M.shebang_map = {
    {"python", "python"}, {"node", "javascript"}, {"ruby", "ruby"},
    {"perl", "perl"}, {"lua", "lua"}, {"php", "php"}, {"sh", "sh"},
}

-- @chk:12 Classify file language via extension or shebang
-- accepts `first_line` to avoid reopening the file
function M.get_lang(filepath, first_line)
    local ext = match(filepath, "%.([^%.]+)$")
    if ext and M.ext_map[ext] then return M.ext_map[ext] end
    if first_line and sub(first_line, 1, 3) == "#!/" then
        for _, pair in ipairs(M.shebang_map) do
            if find(first_line, pair[1], 1, true) then
                return pair[2]
            end
        end
    end
    return ""
end

return M
