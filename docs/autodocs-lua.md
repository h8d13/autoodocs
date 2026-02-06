# autodocs.lua

`~/Desktop/autoodocs/autodocs.lua`

## Contents

- [Checks](#chk)
- [Defines](#def)
- [Runners](#run)

## <a id="chk"></a>Checks

<a id="chk-1"></a>**1.** `~/Desktop/autoodocs/autodocs.lua:2`

`-s` outputs extra stats


<a id="chk-2"></a>**2. ~/Desktop/autoodocs/autodocs.lua:103**
*↳ [@run 2.](#run-2)*

Verify tagged files were discovered

```lua
    if #files == 0 then
```

## <a id="def"></a>Defines

<a id="def-1"></a>**1.** `~/Desktop/autoodocs/autodocs.lua:10`

> [!IMPORTANT]
> Defines with 9 line of subject

And a important callout style

after the end of comment block

`!n` NOTE

`!t` TIP

`!w` WARN

`!c` CAUTION

```lua
print('luadoc is awesome')
    -- Check  -> Early checks
    ---- guard the entry, bail early if preconditions fail
    -- Define -> Gives instructions to
    ---- define the state/config the rest depends on
    -- Run    -> Use the instructions
    ---- do the actual work using those definitions
    -- Error  -> Handle what went wrong
    ---- handle errors with more definitions
```

<a id="def-2"></a>**2.** `~/Desktop/autoodocs/autodocs.lua:31`

Localize functions and load libraries

```lua
local match  = string.match
local gsub   = string.gsub
local sub    = string.sub
local fmt    = string.format
```

<a id="def-3"></a>**3.** `~/Desktop/autoodocs/autodocs.lua:42`

Parse CLI args with defaults

> strip trailing slash, resolve absolute path via `/proc/self/environ`

> `US` separates multi-line text within record fields

```lua
local SCAN_DIR = arg[1] or "."
local OUT_DIR  = arg[2] or "docs"
local STATS    = arg[3] == "-s"
SCAN_DIR = gsub(SCAN_DIR, "/$", "")
if sub(SCAN_DIR, 1, 1) ~= "/" then
    local ef = open("/proc/self/environ", "rb")
    local cwd = ef and match(ef:read("*a"), "PWD=([^%z]+)")
    if ef then ef:close() end
    SCAN_DIR = (SCAN_DIR == ".") and cwd or cwd .. "/" .. SCAN_DIR
end
```

<a id="def-4"></a>**4.** `~/Desktop/autoodocs/autodocs.lua:58`

Global state for collected records and line count

```lua
local records = {}
local total_input = 0
```

## <a id="run"></a>Runners

<a id="run-1"></a>**1.** `~/Desktop/autoodocs/autodocs.lua:62`

Write file if content changed


<a id="run-2"></a>**2.** `~/Desktop/autoodocs/autodocs.lua:78`

Main function

```lua
local function main()
```

<a id="run-2-1"></a>**2.1 ~/Desktop/autoodocs/autodocs.lua:80**
*↳ [@run 2.](#run-2)*

Create output directory


<a id="run-2-2"></a>**2.2 ~/Desktop/autoodocs/autodocs.lua:83**
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
        'grep -rl -I --exclude-dir=.git --exclude-dir=%s --exclude="*.html" %s -e "@def" -e "@chk" -e "@run" -e "@err" %s 2>/dev/null',
        match(OUT_DIR, "([^/]+)$") or OUT_DIR, gi, utils.shell_quote(SCAN_DIR)
    )
    local pipe = io.popen(cmd)
    local files = {}
    for line in pipe:lines() do
        files[#files + 1] = line
    end
    pipe:close()
```

<a id="run-2-3"></a>**2.3 ~/Desktop/autoodocs/autodocs.lua:109**
*↳ [@run 2.](#run-2)*

Process all discovered files into intermediate `records`

```lua
    for _, fp in ipairs(files) do
        total_input = total_input + parser.process_file(fp, records, HOME, US)
    end

    -- @chk:1 Verify extraction produced results
```

<a id="run-2-4"></a>**2.4 ~/Desktop/autoodocs/autodocs.lua:120**
*↳ [@run 2.](#run-2)*

Group and index records by file

```lua
    local by_file, file_order = render.group_records(records)
```

<a id="run-2-5"></a>**2.5 ~/Desktop/autoodocs/autodocs.lua:123**
*↳ [@run 2.](#run-2)*

Write index page


<a id="run-2-6"></a>**2.6 ~/Desktop/autoodocs/autodocs.lua:130**
*↳ [@run 2.](#run-2)*

Write individual file pages


<a id="run-3"></a>**3.** `~/Desktop/autoodocs/autodocs.lua:145`

Entry point

```lua
main()
```

