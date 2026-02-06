# autoodocs.lua

`~/Desktop/autoodocs/autoodocs.lua`

Documentation generator that extracts tagged comments from source files

This library is built to generate docs from source code.

It is also made for AI to auto document it's code in a structured human readable format.

This creates a pleasing flow to work with for docs/ pages.

## <a id="chk"></a>Checks

### <a id="chk-1"></a>`-s` outputs extra stats

`~/Desktop/autoodocs/autoodocs.lua:12`


## <a id="def"></a>Defines

### <a id="def-1"></a>

`~/Desktop/autoodocs/autoodocs.lua:14`

> [!IMPORTANT]
> we define `:` then `n` the amount of subject

and optionally a callout:

`!n` NOTE

`!t` TIP

`!w` WARN

`!c` CAUTION

```lua
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
```

### <a id="def-2"></a>Localize functions and load libraries

`~/Desktop/autoodocs/autoodocs.lua:38`

```lua
local match  = string.match
local gsub   = string.gsub
local sub    = string.sub
local fmt    = string.format
local open   = io.open

-- Set package path relative to script location
local script_dir = arg[0]:match("^(.-)[^/]*$") or "./"
package.path = script_dir .. "?.lua;" .. script_dir .. "?/init.lua;" .. package.path
```

### <a id="def-3"></a>Parse CLI args with defaults

`~/Desktop/autoodocs/autoodocs.lua:53`

strip trailing slash, resolve absolute path via `/proc/self/environ`

> `US` separates multi-line text within record fields

> `-c` enables subject count validation

```lua
local SCAN_DIR = arg[1] or "."
local OUT_DIR  = arg[2] or "docs"
local STATS    = arg[3] == "-s" or arg[4] == "-s"
local CHECK    = arg[3] == "-c" or arg[4] == "-c"
SCAN_DIR = gsub(SCAN_DIR, "/$", "")
if sub(SCAN_DIR, 1, 1) ~= "/" then
    local ef = open("/proc/self/environ", "rb")
    local cwd = ef and match(ef:read("*a"), "PWD=([^%z]+)")
    if ef then ef:close() end
    SCAN_DIR = (SCAN_DIR == ".") and cwd or cwd .. "/" .. SCAN_DIR
end
local HOME = match(SCAN_DIR, "^(/[^/]+/[^/]+)")
local US = "\031"
```

### <a id="def-4"></a>Global state for collected records, warnings, and line count

`~/Desktop/autoodocs/autoodocs.lua:71`

see *↳ [lib/parser.lua:195](parser-lua.html#chk-16)* for file processing

```lua
local records = {}
local warnings = {}
local total_input = 0
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Write file if content changed

`~/Desktop/autoodocs/autoodocs.lua:77`


### <a id="run-2"></a>Main function

`~/Desktop/autoodocs/autoodocs.lua:93`

```lua
local function main()
```

<a id="run-2-1"></a>**2.1 ~/Desktop/autoodocs/autoodocs.lua:95**
*↳ [@run 2.](#run-2)*

Create output directory


<a id="run-2-2"></a>**2.2 ~/Desktop/autoodocs/autoodocs.lua:98**
*↳ [@run 2.](#run-2)*

Discover files containing documentation tags

> respect `.gitignore` patterns via `grep --exclude-from`

```lua
    local gi = ""
    local gf = open(SCAN_DIR .. "/.gitignore", "r")
    if gf then
        gf:close()
        gi = "--exclude-from=" .. utils.shell_quote(SCAN_DIR .. "/.gitignore")
    end

    local cmd = fmt(
        'grep -rl -I --exclude-dir=".*" --exclude-dir=%s --exclude="*.html" %s -e "@def" -e "@chk" -e "@run" -e "@err" %s 2>/dev/null',
        match(OUT_DIR, "([^/]+)$") or OUT_DIR, gi, utils.shell_quote(SCAN_DIR)
    )
    local pipe = io.popen(cmd)
    local files = {}
    for line in pipe:lines() do
        files[#files + 1] = line
    end
    pipe:close()
```

<a id="run-2-3"></a>**2.3 ~/Desktop/autoodocs/autoodocs.lua:124**
*↳ [@run 2.](#run-2)*

Process all discovered files into intermediate `records`

```lua
    for _, fp in ipairs(files) do
        total_input = total_input + parser.process_file(fp, records, HOME, US, CHECK and warnings)
    end
```

<a id="run-2-4"></a>**2.4 ~/Desktop/autoodocs/autoodocs.lua:135**
*↳ [@run 2.](#run-2)*

Group and index records by file

```lua
    local by_file, file_order = render.group_records(records)
```

<a id="run-2-5"></a>**2.5 ~/Desktop/autoodocs/autoodocs.lua:138**
*↳ [@run 2.](#run-2)*

Write index page


<a id="run-2-6"></a>**2.6 ~/Desktop/autoodocs/autoodocs.lua:145**
*↳ [@run 2.](#run-2)*

Write individual file pages


<a id="run-2-7"></a>**2.7 ~/Desktop/autoodocs/autoodocs.lua:159**
*↳ [@run 2.](#run-2)*

Output subject count warnings if check mode enabled

```lua
    if CHECK and #warnings > 0 then
        io.stderr:write(fmt("autoodocs: %d subject count warnings:\n", #warnings))
        for _, w in ipairs(warnings) do
            io.stderr:write(fmt("  %s:%s @%s:%d ends mid-block\n", w.file, w.line, w.tag, w.count))
        end
    end
```

<a id="run-2-8"></a>**2.8 ~/Desktop/autoodocs/autoodocs.lua:167**
*↳ [@run 2.](#run-2)*

Output stats if requested

```lua
    if STATS then
        os.execute(fmt("awk -f " .. script_dir .. "stats.awk %s/*.md", OUT_DIR))
    end
end
```

### <a id="run-3"></a>Entry point

`~/Desktop/autoodocs/autoodocs.lua:173`

```lua
main()
```

