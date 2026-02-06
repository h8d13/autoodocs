# autodocs.lua

`~/Desktop/autoodocs/autodocs.lua`

## <a id="chk"></a>Checks

### <a id="chk-1"></a>`-s` outputs extra stats

`~/Desktop/autoodocs/autodocs.lua:2`


<a id="chk-2"></a>**2. ~/Desktop/autoodocs/autodocs.lua:103**
*↳ [@run 2.](#run-2)*

Verify tagged files were discovered

```lua
    if #files == 0 then
        io.stderr:write(fmt("autodocs: no tags found under %s\n", SCAN_DIR))
        return
    end
```

<a id="chk-3"></a>**3. ~/Desktop/autoodocs/autodocs.lua:114**
*↳ [@run 2.](#run-2)*

Verify extraction produced results

```lua
    if #records == 0 then
        io.stderr:write(fmt("autodocs: tags found but no extractable docs under %s\n", SCAN_DIR))
        return
    end
```

## <a id="def"></a>Defines

### <a id="def-1"></a>

`~/Desktop/autoodocs/autodocs.lua:9`

> [!IMPORTANT]
> And a important callout style

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

### <a id="def-2"></a>Localize functions and load libraries

`~/Desktop/autoodocs/autodocs.lua:30`

```lua
local match  = string.match
local gsub   = string.gsub
local sub    = string.sub
local fmt    = string.format
local open   = io.open
```

### <a id="def-3"></a>Parse CLI args with defaults

`~/Desktop/autoodocs/autodocs.lua:41`

strip trailing slash, resolve absolute path via `/proc/self/environ`

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
local HOME = match(SCAN_DIR, "^(/[^/]+/[^/]+)")
local US = "\031"
```

### <a id="def-4"></a>Global state for collected records and line count

`~/Desktop/autoodocs/autodocs.lua:57`

see [lib/parser.lua:195](parser-lua.html) for file processing

```lua
local records = {}
local total_input = 0
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Write file if content changed

`~/Desktop/autoodocs/autodocs.lua:62`


### <a id="run-2"></a>Main function

`~/Desktop/autoodocs/autodocs.lua:78`

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


<a id="run-2-7"></a>**2.7 ~/Desktop/autoodocs/autodocs.lua:144**
*↳ [@run 2.](#run-2)*

Output stats if requested

```lua
    if STATS then
        os.execute(fmt("awk -f stats.awk %s/*.md", OUT_DIR))
```

### <a id="run-3"></a>Entry point

`~/Desktop/autoodocs/autodocs.lua:150`

```lua
main()
```

