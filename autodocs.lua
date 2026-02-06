#!/usr/bin/env lua
-- @chk:1
-- `-s` outputs extra stats

--########--
--HLPARSER--
--Examples--
--########--

-- @def:9!i
-- Defines with 9 line of subject
-- And a important callout style
-- after the end of comment block
-- `!n` NOTE
-- `!t` TIP
-- `!w` WARN
-- `!c` CAUTION
print('luadoc is awesome')
    -- Check  -> Early checks
    ---- guard the entry, bail early if preconditions fail
    -- Define -> Gives instructions to
    ---- define the state/config the rest depends on
    -- Run    -> Use the instructions
    ---- do the actual work using those definitions
    -- Error  -> Handle what went wrong
    ---- handle errors with more definitions

--########--
-- RUNNER

-- @def:4 Localize functions and load libraries
local match  = string.match
local gsub   = string.gsub
local sub    = string.sub
local fmt    = string.format
local open   = io.open

local utils  = require("lib.utils")
local parser = require("lib.parser")
local render = require("lib.render")

-- @def:13 Parse CLI args with defaults
-- strip trailing slash, resolve absolute path via `/proc/self/environ`
-- `US` separates multi-line text within record fields
local SCAN_DIR = arg[1] or "."
local OUTPUT   = arg[2] or "readme.md"
local STATS    = arg[3] == "-s"
SCAN_DIR = gsub(SCAN_DIR, "/$", "")
if sub(SCAN_DIR, 1, 1) ~= "/" then
    local ef = open("/proc/self/environ", "rb")
    local cwd = ef and match(ef:read("*a"), "PWD=([^%z]+)")
    if ef then ef:close() end
    SCAN_DIR = (SCAN_DIR == ".") and cwd or cwd .. "/" .. SCAN_DIR
end
local HOME = match(SCAN_DIR, "^(/[^/]+/[^/]+)")
local US = "\031"

-- @def:2 Global state for collected records and line count
local records = {}
local total_input = 0

-- @run:1 Main function
local function main()
    -- @run:17 Discover files containing documentation tags
    -- respect `.gitignore` patterns via `grep --exclude-from`
    local gi = ""
    local gf = open(SCAN_DIR .. "/.gitignore", "r")
    if gf then
        gf:close()
        gi = "--exclude-from=" .. utils.shell_quote(SCAN_DIR .. "/.gitignore")
    end

    local cmd = fmt(
        'grep -rl -I --exclude-dir=.git --exclude="readme*" %s -e "@def" -e "@chk" -e "@run" -e "@err" %s 2>/dev/null',
        gi, utils.shell_quote(SCAN_DIR)
    )
    local pipe = io.popen(cmd)
    local files = {}
    for line in pipe:lines() do
        files[#files + 1] = line
    end
    pipe:close()

    -- @chk:1 Verify tagged files were discovered
    if #files == 0 then
        -- @err:5 Handle missing tagged files
        -- with empty output and `stderr` warning
        local f = open(OUTPUT, "w")
        f:write("No tagged documentation found.\n")
        f:close()
        io.stderr:write(fmt("autodocs: no tags found under %s\n", SCAN_DIR))
        return
    end

    local out_base = match(OUTPUT, "([^/]+)$")
    local out_base_escaped = gsub(out_base, "(%W)", "%%%1")

    -- @run:5 Process all discovered files into intermediate `records`
    for _, fp in ipairs(files) do
        if not match(fp, "/" .. out_base_escaped .. "$") then
            total_input = total_input + parser.process_file(fp, records, HOME, US)
        end
    end

    -- @chk:1 Verify extraction produced results
    if #records == 0 then
        -- @err:5 Handle extraction failure
        -- with empty output and `stderr` warning
        local f = open(OUTPUT, "w")
        f:write("No tagged documentation found.\n")
        f:close()
        io.stderr:write(fmt("autodocs: tags found but no extractable docs under %s\n", SCAN_DIR))
        return
    end

    -- @run:1 Group and index records
    local grouped = render.group_records(records)

    -- @chk:10 Render and compare against existing output
    -- skip write if content is unchanged
    local markdown = render.render_markdown(grouped)
    local ef = open(OUTPUT, "r")
    if ef then
        local existing = ef:read("*a")
        ef:close()
        if existing == markdown then
            io.stderr:write(fmt("autodocs: %s unchanged\n", OUTPUT))
            return
        end
    end

    -- @run:6 Write output and report ratio
    -- wraps across two lines so `:N` count must include the continuation
    local f = open(OUTPUT, "w")
    f:write(markdown)
    f:close()
    local ol = select(2, gsub(markdown, "\n", "")) + 1
    io.stderr:write(fmt("autodocs: wrote %s (%d/%d = %d%%)\n",
        OUTPUT, ol, total_input, total_input > 0 and math.floor(ol * 100 / total_input) or 0))

    -- @run:9 Run `stats.awk` on the output if `-s` flag is set
    if STATS then
        local script_dir = match(arg[0], "^(.*/)") or "./"
        local stats_awk = script_dir .. "stats.awk"
        local sf = open(stats_awk, "r")
        if sf then
            sf:close()
            os.execute(fmt("awk -f %s %s >&2", utils.shell_quote(stats_awk), utils.shell_quote(OUTPUT)))
        end
    end
end

-- @run:1 Entry point
main()
