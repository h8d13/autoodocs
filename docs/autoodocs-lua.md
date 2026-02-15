# autoodocs.lua

`~/Desktop/autoodocs/autoodocs.lua`

Documentation generator that extracts tagged comments from source files

This library is built to generate docs from source code.

It is also made for AI to auto document it's code in a structured human readable format.

This creates a pleasing flow to work with for docs/ pages.

## <a id="chk"></a>Checks

### <a id="chk-1"></a>1. `-s` outputs extra stats

`~/Desktop/autoodocs/autoodocs.lua:12`


## <a id="def"></a>Defines

### <a id="def-1"></a>1. 

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
    -- STANDALONES (Place anywhere)
        -- @gen General -> File description
        ---- plain text at top, no section header
        -- @chk Check  -> Early checks
        ---- guard the entry, bail/handle early if preconditions fail
        -- @def Define -> Gives instructions to
        ---- define the state/config the rest depends on
        -- @run Run    -> Use the instructions
        ---- do the actual work using those definitions
        -- @err Error  -> Handle what went wrong
        ---- handle errors with more definitions
    -- Descriptions (Used inside another of above)
        -- @src Source -> Reference a line nbr
        ---- mention line nr auto resolve anchor
        -- @ref Reference -> External link
        ---- renders clickable arrow link in quote
```

### <a id="def-2"></a>2. Localize functions and load libraries

`~/Desktop/autoodocs/autoodocs.lua:42`

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

### <a id="def-3"></a>3. Parse CLI args with defaults

`~/Desktop/autoodocs/autoodocs.lua:57`

strip trailing slash, resolve absolute path via `/proc/self/environ`

> `US` separates multi-line text within record fields

> `-c` enables subject count validation, `-r` sets repo URL

```lua
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
```

### <a id="def-4"></a>4. Global state for collected records, warnings, and line count

`~/Desktop/autoodocs/autoodocs.lua:80`

see *↳ [lib/parser.lua:195](parser-lua.html#chk-16)* for file processing

```lua
local records = {}
local warnings = {}
local total_input = 0
```

## <a id="run"></a>Runners

### <a id="run-1"></a>1. Write file if content changed

`~/Desktop/autoodocs/autoodocs.lua:86`


### <a id="run-2"></a>2. Main function

`~/Desktop/autoodocs/autoodocs.lua:102`

```lua
local function main()
```

<a id="run-2-1"></a>**2.1 ~/Desktop/autoodocs/autoodocs.lua:104**
*↳ [@run 2.](#run-2)*

Create output directory


<a id="run-2-2"></a>**2.2 ~/Desktop/autoodocs/autoodocs.lua:107**
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
        'grep -rl -I --exclude-dir=".*" --exclude-dir=%s --exclude="*.html" --exclude="[Rr][Ee][Aa][Dd][Mm][Ee].[Mm][Dd]" %s -e "@def" -e "@chk" -e "@run" -e "@err" %s 2>/dev/null',
        match(OUT_DIR, "([^/]+)$") or OUT_DIR, gi, utils.shell_quote(SCAN_DIR)
    )
    local pipe = io.popen(cmd)
    local files = {}
    for line in pipe:lines() do
        files[#files + 1] = line
    end
    pipe:close()
```

<a id="run-2-3"></a>**2.3 ~/Desktop/autoodocs/autoodocs.lua:133**
*↳ [@run 2.](#run-2)*

Process all discovered files into intermediate `records`

```lua
    for _, fp in ipairs(files) do
        total_input = total_input + parser.process_file(fp, records, HOME, US, CHECK and warnings)
    end
```

<a id="run-2-4"></a>**2.4 ~/Desktop/autoodocs/autoodocs.lua:144**
*↳ [@run 2.](#run-2)*

Group and index records by file

```lua
    local by_file, file_order = render.group_records(records)
```

<a id="run-2-5"></a>**2.5 ~/Desktop/autoodocs/autoodocs.lua:147**
*↳ [@run 2.](#run-2)*

Write index page


<a id="run-2-6"></a>**2.6 ~/Desktop/autoodocs/autoodocs.lua:154**
*↳ [@run 2.](#run-2)*

Write individual file pages


<a id="run-2-7"></a>**2.7 ~/Desktop/autoodocs/autoodocs.lua:168**
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

<a id="run-2-8"></a>**2.8 ~/Desktop/autoodocs/autoodocs.lua:176**
*↳ [@run 2.](#run-2)*

Output stats if requested

```lua
    if STATS then
        os.execute(fmt("awk -f " .. script_dir .. "stats.awk %s/*.md", OUT_DIR))
    end
end
```

### <a id="run-3"></a>3. Entry point

`~/Desktop/autoodocs/autoodocs.lua:182`

```lua
main()
```

## <a id="err"></a>Errors

<a id="err-1"></a>**1. ~/Desktop/autoodocs/autoodocs.lua:127**
*↳ [@run 2.](#run-2)*

No tagged files found

```lua
    if #files == 0 then
        io.stderr:write(fmt("autoodocs: no tags found under %s\n", SCAN_DIR))
        return
    end
```

<a id="err-2"></a>**2. ~/Desktop/autoodocs/autoodocs.lua:138**
*↳ [@run 2.](#run-2)*

No extractable documentation

```lua
    if #records == 0 then
        io.stderr:write(fmt("autoodocs: tags found but no extractable docs under %s\n", SCAN_DIR))
        return
    end
```

