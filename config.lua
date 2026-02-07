-- @gen Autoodocs configuration

-- @def:8 Configuration for build
-- [2] opt args and in/out dirs
return {
    cmd      = "luajit",  -- Lua interpreter (lua, luajit)
    scan_dir = ".",       -- Directory to scan for tagged comments
    out_dir  = "docs",    -- Output directory for generated docs
    stats    = true,      -- Show statistics after generation
    check    = true,      -- Validate subject line counts
    repo     = "https://github.com/h8d13/autoodocs",
}
