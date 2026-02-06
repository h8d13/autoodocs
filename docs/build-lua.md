# build.lua

`~/Desktop/autoodocs/build.lua`

Build script that runs autoodocs and converts output to HTML

## <a id="def"></a>Defines

### <a id="def-1"></a>Resolve script directory for portable paths

`~/Desktop/autoodocs/build.lua:5`

```lua
local fmt = string.format
local dir = arg[0]:match("^(.-)[^/]*$") or "./"
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Build pipeline: generate docs and convert to HTML

`~/Desktop/autoodocs/build.lua:3`


### <a id="run-2"></a>Generate markdown documentation

`~/Desktop/autoodocs/build.lua:9`

*↳ [autoodocs.lua:82](autoodocs-lua.html#run-1)*

```lua
print("Generating markdown...")
os.execute(fmt("lua %sautoodocs.lua . docs -s", dir))
```

### <a id="run-3"></a>Copy stylesheet to output directory

`~/Desktop/autoodocs/build.lua:14`

*↳ [default.css](default-css.html)*

```lua
print("Copying assets...")
os.execute(fmt("cp %sdefault.css docs/", dir))
```

### <a id="run-4"></a>Convert all markdown files to HTML

`~/Desktop/autoodocs/build.lua:19`

*↳ [markdown.lua:1264](markdown-lua.html#run-9)*

```lua
print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    os.execute(fmt("lua %smarkdown.lua %s", dir, md))
end
pipe:close()
```

