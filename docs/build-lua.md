# build.lua

`~/Desktop/autoodocs/build.lua`

Build script that runs autoodocs and converts output to HTML

## <a id="chk"></a>Checks

### <a id="chk-1"></a>Get file modification time via stat

`~/Desktop/autoodocs/build.lua:16`

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

### <a id="def-2"></a>Load config from script directory

`~/Desktop/autoodocs/build.lua:9`

```lua
local cfg = { cmd = "lua", scan_dir = ".", out_dir = "docs", stats = true, check = true }
local conf_file = loadfile(dir .. "config.lua")
if conf_file then
    for k, v in pairs(conf_file()) do cfg[k] = v end
end
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Build pipeline: generate docs and convert to HTML

`~/Desktop/autoodocs/build.lua:3`


### <a id="run-2"></a>Generate markdown documentation

`~/Desktop/autoodocs/build.lua:24`

Flags based on config

> *↳ [autoodocs.lua:82](autoodocs-lua.html#run-1)*

```lua
local flags = (cfg.stats and "-s " or "") .. (cfg.check and "-c" or "")
print("Generating markdown...")
os.execute(fmt("%s %sautoodocs.lua %s %s %s", cfg.cmd, dir, cfg.scan_dir, cfg.out_dir, flags))
```

### <a id="run-3"></a>Copy stylesheet to output directory

`~/Desktop/autoodocs/build.lua:31`

*↳ [default.css](default-css.html)*

```lua
print("Copying assets...")
os.execute(fmt("cp %sdefault.css %s/", dir, cfg.out_dir))
```

### <a id="run-4"></a>Convert changed markdown files to HTML

`~/Desktop/autoodocs/build.lua:36`

*↳ [markdown.lua:1264](markdown-lua.html#run-9)*

```lua
print("Converting to HTML...")
local pipe = io.popen(fmt("ls %s/*.md 2>/dev/null", cfg.out_dir))
for md in pipe:lines() do
    local html = md:gsub("%.md$", ".html")
    if mtime(md) > mtime(html) then
        os.execute(fmt("%s %smarkdown.lua %s", cfg.cmd, dir, md))
    end
end
pipe:close()
```

