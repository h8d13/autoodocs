# build.lua

`~/Desktop/autoodocs/build.lua`

Build script that runs autodocs and converts output to HTML

## <a id="def"></a>Defines

### <a id="def-1"></a>Localize format function

`~/Desktop/autoodocs/build.lua:5`

```lua
local fmt = string.format
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Build pipeline: generate docs and convert to HTML

`~/Desktop/autoodocs/build.lua:3`


### <a id="run-2"></a>Generate markdown documentation

`~/Desktop/autoodocs/build.lua:8`

[autodocs.lua:82](autodocs-lua.html#run-2)

```lua
print("Generating markdown...")
os.execute("lua autodocs.lua . docs -s")
```

### <a id="run-3"></a>Copy stylesheet to output directory

`~/Desktop/autoodocs/build.lua:13`

```lua
print("Copying assets...")
os.execute("cp default.css docs/")
```

### <a id="run-4"></a>Convert all markdown files to HTML

`~/Desktop/autoodocs/build.lua:17`

[markdown.lua:1264](markdown-lua.html#run-10)

```lua
print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    os.execute(fmt("lua markdown.lua %s", md))
end
pipe:close()
```

