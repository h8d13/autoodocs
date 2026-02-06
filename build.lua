#!/usr/bin/env lua
-- @gen Build script that runs autodocs and converts output to HTML
-- @run Build pipeline: generate docs and convert to HTML

-- @def:1 Localize format function
local fmt = string.format

-- @run:2 Generate markdown documentation
-- @src:autodocs.lua:82
print("Generating markdown...")
os.execute("lua autodocs.lua . docs -s")

-- @run:2 Copy stylesheet to output directory
print("Copying assets...")
os.execute("cp default.css docs/")

-- @run:6 Convert all markdown files to HTML
-- @src:markdown.lua:1264
print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    os.execute(fmt("lua markdown.lua %s", md))
end
pipe:close()

print("Done! Open docs/index.html")
