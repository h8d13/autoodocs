# config.lua

`~/Desktop/autoodocs/config.lua`

Autoodocs configuration

## <a id="def"></a>Defines

### <a id="def-1"></a>Configuration for build

`~/Desktop/autoodocs/config.lua:3`

[2] opt args and in/out dirs

```lua
return {
    cmd      = "luajit",  -- Lua interpreter (lua, luajit)
    scan_dir = ".",       -- Directory to scan for tagged comments
    out_dir  = "docs",    -- Output directory for generated docs
    stats    = true,      -- Show statistics after generation
    check    = true,      -- Validate subject line counts
    repo     = "https://github.com/h8d13/autoodocs",

    -- HTML customization (passed to markdown.lua)
    -- header       = nil,       -- Custom header HTML file (-e)
    -- footer       = nil,       -- Custom footer HTML file (-f)
    -- stylesheet   = nil,       -- Custom CSS file (default: default.css)
    -- inline_style = false,     -- Embed CSS inline in <style> tags
    -- favicon      = nil,       -- Favicon file (copied to out_dir)
   	timestamp    = true,     -- Add build timestamp to footer
}
```

