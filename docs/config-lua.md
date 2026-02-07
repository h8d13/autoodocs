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
}
```

