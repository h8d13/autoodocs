#!/usr/bin/env lua
-- Build: generate docs and convert to HTML

local fmt = string.format
local stats = arg[1] == "-s"

print("Generating markdown...")
os.execute("lua autodocs.lua . docs")

print("Copying assets...")
os.execute("cp default.css docs/")

print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    os.execute(fmt("lua markdown.lua %s", md))
end
pipe:close()

if stats then
    os.execute("awk -f stats.awk docs/*.md")
end

print("Done! Open docs/index.html")
