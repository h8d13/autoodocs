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

### <a id="def-2"></a>Load config from script directory

`~/Desktop/autoodocs/build.lua:9`

```lua
local cfg = { cmd = "lua", scan_dir = ".", out_dir = "docs", stats = true, check = true, repo = "" }
local conf_file = loadfile(dir .. "config.lua")
if conf_file then
    for k, v in pairs(conf_file()) do cfg[k] = v end
end
```

### <a id="def-3"></a>Build markdown.lua flags from config

`~/Desktop/autoodocs/build.lua:25`

```lua
local md_flags = ""
if cfg.header then md_flags = md_flags .. fmt("-e %s ", cfg.header) end
if cfg.footer then md_flags = md_flags .. fmt("-f %s ", cfg.footer) end
if cfg.stylesheet then md_flags = md_flags .. fmt("-s %s ", cfg.stylesheet) end
if cfg.inline_style then md_flags = md_flags .. "-l " end
if cfg.favicon then md_flags = md_flags .. fmt("--favicon %s ", cfg.favicon) end
if cfg.timestamp then md_flags = md_flags .. fmt('--timestamp "%s" ', os.date("%Y-%m-%d %H:%M")) end
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Build pipeline: generate docs and convert to HTML

`~/Desktop/autoodocs/build.lua:3`


### <a id="run-2"></a>Generate markdown documentation

`~/Desktop/autoodocs/build.lua:17`

Flags based on config

> *↳ [autoodocs.lua:82](autoodocs-lua.html#def-4)*

```lua
local flags = (cfg.stats and "-s " or "") .. (cfg.check and "-c " or "")
local repo = cfg.repo ~= "" and ("-r " .. cfg.repo) or ""
print("Generating markdown...")
os.execute(fmt("%s %sautoodocs.lua %s %s %s%s", cfg.cmd, dir, cfg.scan_dir, cfg.out_dir, flags, repo))
```

### <a id="run-3"></a>Copy stylesheet and assets to output directory

`~/Desktop/autoodocs/build.lua:34`

*↳ [default.css](default-css.html)*

```lua
print("Copying assets...")
os.execute(fmt("cp %sdefault.css %s/", dir, cfg.out_dir))
if cfg.stylesheet and cfg.stylesheet ~= "default.css" then
    os.execute(fmt("cp %s %s/", cfg.stylesheet, cfg.out_dir))
end
if cfg.favicon then
    os.execute(fmt("cp %s %s/", cfg.favicon, cfg.out_dir))
end
```

### <a id="run-4"></a>Convert all markdown files to HTML

`~/Desktop/autoodocs/build.lua:45`

*↳ [markdown.lua](markdown-lua.html)*

```lua
print("Converting to HTML...")
local pipe = io.popen(fmt("ls %s/*.md 2>/dev/null", cfg.out_dir))
for md in pipe:lines() do
    os.execute(fmt("%s %smarkdown.lua %s%s", cfg.cmd, dir, md_flags, md))
end
pipe:close()
```

