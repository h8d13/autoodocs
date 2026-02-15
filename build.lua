#!/usr/bin/env lua
-- @gen Build script that runs autoodocs and converts output to HTML
-- @run Build pipeline: generate docs and convert to HTML

-- @def:2 Resolve script directory for portable paths
local fmt = string.format
local dir = arg[0]:match("^(.-)[^/]*$") or "./"

-- @def:5 Load config from script directory
local cfg = { cmd = "lua", scan_dir = ".", out_dir = "docs", stats = true, check = true, repo = "" }
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

-- @run:4 Generate markdown documentation
-- Flags based on config
-- @src:autoodocs.lua:82
local flags = (cfg.stats and "-s " or "") .. (cfg.check and "-c " or "")
local repo = cfg.repo ~= "" and ("-r " .. cfg.repo) or ""
print("Generating markdown...")
os.execute(fmt("%s %sautoodocs.lua %s %s %s%s", cfg.cmd, dir, cfg.scan_dir, cfg.out_dir, flags, repo))

-- Build markdown.lua flags from config
local md_flags = ""
if cfg.header then md_flags = md_flags .. fmt("-e %s ", cfg.header) end
if cfg.footer then md_flags = md_flags .. fmt("-f %s ", cfg.footer) end
if cfg.stylesheet then md_flags = md_flags .. fmt("-s %s ", cfg.stylesheet) end
if cfg.inline_style then md_flags = md_flags .. "-l " end
if cfg.favicon then md_flags = md_flags .. fmt("--favicon %s ", cfg.favicon) end
if cfg.timestamp then md_flags = md_flags .. fmt('--timestamp "%s" ', os.date("%Y-%m-%d %H:%M")) end

-- @run:9 Copy stylesheet and assets to output directory
-- @src:default.css
print("Copying assets...")
os.execute(fmt("cp %sdefault.css %s/", dir, cfg.out_dir))
if cfg.stylesheet and cfg.stylesheet ~= "default.css" then
    os.execute(fmt("cp %s %s/", cfg.stylesheet, cfg.out_dir))
end
if cfg.favicon then
    os.execute(fmt("cp %s %s/", cfg.favicon, cfg.out_dir))
end

-- @run:9 Convert changed markdown files to HTML
-- @src:markdown.lua:1264
print("Converting to HTML...")
local pipe = io.popen(fmt("ls %s/*.md 2>/dev/null", cfg.out_dir))
for md in pipe:lines() do
    local html = md:gsub("%.md$", ".html")
    if mtime(md) > mtime(html) then
        os.execute(fmt("%s %smarkdown.lua %s%s", cfg.cmd, dir, md_flags, md))
    end
end
pipe:close()

print(fmt("Done! Open %s/index.html", cfg.out_dir))
