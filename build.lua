#!/usr/bin/env lua
-- Build: generate docs and convert to HTML

local fmt = string.format

print("Generating markdown...")
os.execute("lua autodocs.lua . docs -s")

print("Copying assets...")
os.execute("cp default.css docs/")

print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    os.execute(fmt("lua markdown.lua %s", md))
end
pipe:close()

print("Done! Open docs/index.html")
