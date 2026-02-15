-- @gen Autoodocs configuration

-- @def:17 Configuration for build
-- [2] opt args and in/out dirs
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
    -- timestamp    = false,     -- Add build timestamp to footer
}
