#!/usr/bin/env lua
-- @gen Build script that runs autoodocs and converts output to HTML
-- @run Build pipeline: generate docs and convert to HTML

-- @def:2 Resolve script directory for portable paths
local fmt = string.format
local dir = arg[0]:match("^(.-)[^/]*$") or "./"

-- @def:5 Load config from script directory
local cfg = { cmd = "lua", scan_dir = ".", out_dir = "docs", stats = true, check = true }
local conf_file = loadfile(dir .. "config.lua")
if conf_file then
    for k, v in pairs(conf_file()) do cfg[k] = v end
end

-- @chk:6 Get file modification time via stat
local function mtime(path)
    local p = io.popen(fmt("stat -c %%Y %s 2>/dev/null", path))
    local t = p and tonumber(p:read("*l"))
    if p then p:close() end
    return t or 0
end

-- @run:3 Generate markdown documentation
-- Flags based on config
-- @src:autoodocs.lua:82
local flags = (cfg.stats and "-s " or "") .. (cfg.check and "-c" or "")
print("Generating markdown...")
os.execute(fmt("%s %sautoodocs.lua %s %s %s", cfg.cmd, dir, cfg.scan_dir, cfg.out_dir, flags))

-- @run:2 Copy stylesheet to output directory
-- @src:default.css
print("Copying assets...")
os.execute(fmt("cp %sdefault.css %s/", dir, cfg.out_dir))

-- @run:9 Convert changed markdown files to HTML
-- @src:markdown.lua:1264
print("Converting to HTML...")
local pipe = io.popen(fmt("ls %s/*.md 2>/dev/null", cfg.out_dir))
for md in pipe:lines() do
    local html = md:gsub("%.md$", ".html")
    if mtime(md) > mtime(html) then
        os.execute(fmt("%s %smarkdown.lua %s", cfg.cmd, dir, md))
    end
end
pipe:close()

print(fmt("Done! Open %s/index.html", cfg.out_dir))
