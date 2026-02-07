#!/usr/bin/env lua
-- @gen Documentation generator that extracts tagged comments from source files
-- This library is built to generate docs from source code.
-- It is also made for AI to auto document it's code in a structured human readable format.
-- This creates a pleasing flow to work with for docs/ pages.

--########--
--HLPARSER--
--Examples--
--########--

-- @chk `-s` outputs extra stats

-- @def:13!i
-- after the end of comment block
-- we define `:` then `n` the amount of subject
-- and optionally a callout:
-- `!n` NOTE
-- `!t` TIP
-- `!w` WARN
-- `!c` CAUTION
print('luadoc is awesome')
    -- @chk Check  -> Early checks
    ---- guard the entry, bail early if preconditions fail
    -- @def Define -> Gives instructions to
    ---- define the state/config the rest depends on
    -- @run Run    -> Use the instructions
    ---- do the actual work using those definitions
    -- @err Error  -> Handle what went wrong
    ---- handle errors with more definitions
    -- @gen General -> File description
    ---- plain text at top, no section header
    -- @src Source -> reference a line nbr
    ---- Mention line nr auto resolve anchor

--########--

-- @def:9 Localize functions and load libraries
local match  = string.match
local gsub   = string.gsub
local sub    = string.sub
local fmt    = string.format
local open   = io.open

-- Set package path relative to script location
local script_dir = arg[0]:match("^(.-)[^/]*$") or "./"
package.path = script_dir .. "?.lua;" .. script_dir .. "?/init.lua;" .. package.path

local utils  = require("lib.utils")
local parser = require("lib.parser")
local render = require("lib.render")

-- @def:21 Parse CLI args with defaults
-- strip trailing slash, resolve absolute path via `/proc/self/environ`
-- `US` separates multi-line text within record fields
-- `-c` enables subject count validation, `-r` sets repo URL
local SCAN_DIR = arg[1] or "."
local OUT_DIR  = arg[2] or "docs"
local STATS, CHECK, REPO = false, false, nil
for i = 3, #arg do
    if arg[i] == "-s" then STATS = true
    elseif arg[i] == "-c" then CHECK = true
    elseif arg[i] == "-r" and arg[i+1] then REPO = arg[i+1]
    end
end
SCAN_DIR = gsub(SCAN_DIR, "/$", "")
if sub(SCAN_DIR, 1, 1) ~= "/" then
    local ef = open("/proc/self/environ", "rb")
    local cwd = ef and match(ef:read("*a"), "PWD=([^%z]+)")
    if ef then ef:close() end
    SCAN_DIR = (SCAN_DIR == ".") and cwd or cwd .. "/" .. SCAN_DIR
end
local HOME = match(SCAN_DIR, "^(/[^/]+/[^/]+)")
local US = "\031"

-- @def:3 Global state for collected records, warnings, and line count
-- see @src:lib/parser.lua:195 for file processing
local records = {}
local warnings = {}
local total_input = 0

-- @run Write file if content changed
local function write_if_changed(path, content)
    local ef = open(path, "r")
    if ef then
        local existing = ef:read("*a")
        ef:close()
        if existing == content then
            return false
        end
    end
    local f = open(path, "w")
    f:write(content)
    f:close()
    return true
end

-- @run:1 Main function
local function main()
    -- @run Create output directory
    os.execute(fmt("mkdir -p %s", utils.shell_quote(OUT_DIR)))

    -- @run:17 Discover files containing documentation tags
    -- respect `.gitignore` patterns via `grep --exclude-from`
    local gi = ""
    local gf = open(SCAN_DIR .. "/.gitignore", "r")
    if gf then
        gf:close()
        gi = "--exclude-from=" .. utils.shell_quote(SCAN_DIR .. "/.gitignore")
    end

    local cmd = fmt(
        'grep -rl -I --exclude-dir=".*" --exclude-dir=%s --exclude="*.html" --exclude="[Rr][Ee][Aa][Dd][Mm][Ee].[Mm][Dd]" %s -e "@def" -e "@chk" -e "@run" -e "@err" %s 2>/dev/null',
        match(OUT_DIR, "([^/]+)$") or OUT_DIR, gi, utils.shell_quote(SCAN_DIR)
    )
    local pipe = io.popen(cmd)
    local files = {}
    for line in pipe:lines() do
        files[#files + 1] = line
    end
    pipe:close()

    -- @err:4 No tagged files found
    if #files == 0 then
        io.stderr:write(fmt("autoodocs: no tags found under %s\n", SCAN_DIR))
        return
    end

    -- @run:3 Process all discovered files into intermediate `records`
    for _, fp in ipairs(files) do
        total_input = total_input + parser.process_file(fp, records, HOME, US, CHECK and warnings)
    end

    -- @err:4 No extractable documentation
    if #records == 0 then
        io.stderr:write(fmt("autoodocs: tags found but no extractable docs under %s\n", SCAN_DIR))
        return
    end

    -- @run:1 Group and index records by file
    local by_file, file_order = render.group_records(records)

    -- @run Write index page
    local index_md = render.render_index(file_order, SCAN_DIR, REPO)
    local index_path = OUT_DIR .. "/index.md"
    if write_if_changed(index_path, index_md) then
        io.stderr:write(fmt("autoodocs: wrote %s\n", index_path))
    end

    -- @run Write individual file pages
    local pages_written = 0
    for _, file in ipairs(file_order) do
        local slug = render.slugify(file)
        local page_md = render.render_file_page(file, by_file[file])
        local page_path = fmt("%s/%s.md", OUT_DIR, slug)
        if write_if_changed(page_path, page_md) then
            pages_written = pages_written + 1
            io.stderr:write(fmt("autoodocs: wrote %s\n", page_path))
        end
    end

    io.stderr:write(fmt("autoodocs: %d files documented\n", #file_order))

    -- @run:6 Output subject count warnings if check mode enabled
    if CHECK and #warnings > 0 then
        io.stderr:write(fmt("autoodocs: %d subject count warnings:\n", #warnings))
        for _, w in ipairs(warnings) do
            io.stderr:write(fmt("  %s:%s @%s:%d ends mid-block\n", w.file, w.line, w.tag, w.count))
        end
    end

    -- @run:4 Output stats if requested
    if STATS then
        os.execute(fmt("awk -f " .. script_dir .. "stats.awk %s/*.md", OUT_DIR))
    end
end

-- @run:1 Entry point
main()
