#!/usr/bin/env lua
-- @gen Build script that runs autoodocs and converts output to HTML
-- @run Build pipeline: generate docs and convert to HTML

-- @def:2 Resolve script directory for portable paths
local fmt = string.format
local dir = arg[0]:match("^(.-)[^/]*$") or "./"

-- @chk:6 Get file modification time via stat
local function mtime(path)
    local p = io.popen(fmt("stat -c %%Y %s 2>/dev/null", path))
    local t = p and tonumber(p:read("*l"))
    if p then p:close() end
    return t or 0
end

-- @run:2 Generate markdown documentation
-- With all flags enabled
-- @src:autoodocs.lua:82
print("Generating markdown...")
os.execute(fmt("lua %sautoodocs.lua . docs -s -c", dir))

-- @run:2 Copy stylesheet to output directory
-- @src:default.css
print("Copying assets...")
os.execute(fmt("cp %sdefault.css docs/", dir))

-- @run:9 Convert changed markdown files to HTML
-- @src:markdown.lua:1264
print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    local html = md:gsub("%.md$", ".html")
    if mtime(md) > mtime(html) then
        os.execute(fmt("lua %smarkdown.lua %s", dir, md))
    end
end
pipe:close()

print("Done! Open docs/index.html")
