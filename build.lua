#!/usr/bin/env lua
-- @gen Build script that runs autodocs and converts output to HTML
-- @run Build pipeline: generate docs and convert to HTML

-- @def:2 Resolve script directory for portable paths
local fmt = string.format
local dir = arg[0]:match("^(.-)[^/]*$") or "./"

-- @run:2 Generate markdown documentation
-- @src:autodocs.lua:82
print("Generating markdown...")
os.execute(fmt("lua %sautodocs.lua . docs -s", dir))

-- @run:2 Copy stylesheet to output directory
-- @src:default.css
print("Copying assets...")
os.execute(fmt("cp %sdefault.css docs/", dir))

-- @run:6 Convert all markdown files to HTML
-- @src:markdown.lua:1264
print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    os.execute(fmt("lua %smarkdown.lua %s", dir, md))
end
pipe:close()

print("Done! Open docs/index.html")
