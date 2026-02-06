# build.lua

`~/Desktop/autoodocs/build.lua`

Build script that runs autoodocs and converts output to HTML

## <a id="chk"></a>Checks

### <a id="chk-1"></a>Get file modification time via stat

`~/Desktop/autoodocs/build.lua:9`

```lua
local function mtime(path)
    local p = io.popen(fmt("stat -c %%Y %s 2>/dev/null", path))
    local t = p and tonumber(p:read("*l"))
    if p then p:close() end
    return t or 0
end
```

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

`~/Desktop/autoodocs/build.lua:17`

With all flags enabled

> *↳ [autoodocs.lua:82](autoodocs-lua.html#run-1)*

```lua
print("Generating markdown...")
os.execute(fmt("lua %sautoodocs.lua . docs -s -c", dir))
```

### <a id="run-3"></a>Copy stylesheet to output directory

`~/Desktop/autoodocs/build.lua:23`

*↳ [default.css](default-css.html)*

```lua
print("Copying assets...")
os.execute(fmt("cp %sdefault.css docs/", dir))
```

### <a id="run-4"></a>Convert changed markdown files to HTML

`~/Desktop/autoodocs/build.lua:28`

*↳ [markdown.lua:1264](markdown-lua.html#run-9)*

```lua
print("Converting to HTML...")
local pipe = io.popen("ls docs/*.md 2>/dev/null")
for md in pipe:lines() do
    local html = md:gsub("%.md$", ".html")
    if mtime(md) > mtime(html) then
        os.execute(fmt("lua %smarkdown.lua %s", dir, md))
    end
end
pipe:close()
```

