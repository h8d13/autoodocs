## Contents

- [parser.lua](#parser-lua)
- [utils.lua](#utils-lua)
- [render.lua](#render-lua)
- [autodocs.lua](#autodocs-lua)

---

## <a id="parser-lua"></a>parser.lua

`~/Desktop/autoodocs/lib/parser.lua`

### Checks

<a id="parser-lua-chk-1"></a>**1.** `~/Desktop/autoodocs/lib/parser.lua:24`

Test whether a line contains any documentation tag

> early `@` check short-circuits lines with no tags

```lua
function M.has_tag(line)
    if not find(line, "@", 1, true) then return nil end
    return find(line, "@def", 1, true) or find(line, "@chk", 1, true) or
           find(line, "@run", 1, true) or find(line, "@err", 1, true)
end
```

<a id="parser-lua-chk-2"></a>**2.** `~/Desktop/autoodocs/lib/parser.lua:32`

Classify a tagged line into `DEF`, `CHK`, `RUN`, or `ERR`

```lua
function M.get_tag(line)
    if     find(line, "@def", 1, true) then return "DEF"
    elseif find(line, "@chk", 1, true) then return "CHK"
    elseif find(line, "@run", 1, true) then return "RUN"
    elseif find(line, "@err", 1, true) then return "ERR"
    end
end
```

<a id="parser-lua-chk-3"></a>**3.** `~/Desktop/autoodocs/lib/parser.lua:41`

Extract the subject line count from `@tag:N` syntax

> using pattern capture after the colon

```lua
function M.get_subject_count(text)
    local n = match(text, "@def:(%d+)") or match(text, "@chk:(%d+)") or
              match(text, "@run:(%d+)") or match(text, "@err:(%d+)")
    return tonumber(n) or 0
end
```

<a id="parser-lua-chk-4"></a>**4.** `~/Desktop/autoodocs/lib/parser.lua:61`

Extract `!x` admonition suffix from tag syntax

```lua
function M.get_admonition(text)
    local code = match(text, "@%a+:?%d*!(%a)")
    if code then return M.ADMONITIONS[code] end
end
```

<a id="parser-lua-chk-5"></a>**5.** `~/Desktop/autoodocs/lib/parser.lua:92`

Detect comment style via byte-level prefix check

> skips leading whitespace without allocating a trimmed copy

```lua
function M.detect_style(line)
    local i = 1
    while byte(line, i) == 32 or byte(line, i) == 9 do i = i + 1 end
    local b = byte(line, i)
    if not b then return "none" end
    if b == 60 then -- '<'
        if sub(line, i, i + 3) == "<!--" then return "html" end
    elseif b == 47 then -- '/'
        local b2 = byte(line, i + 1)
        if b2 == 42 then return "cblock" end
        if b2 == 47 then return "dslash" end
    elseif b == 35 then return "hash"
    elseif b == 34 then -- '"'
        if sub(line, i, i + 2) == '"""' then return "dquote" end
    elseif b == 39 then -- "'"
        if sub(line, i, i + 2) == "'''" then return "squote" end
    elseif b == 45 then -- '-'
        if byte(line, i + 1) == 45 then return "ddash" end
    end
    return "none"
end
```

<a id="parser-lua-chk-6"></a>**6. ~/Desktop/autoodocs/lib/parser.lua:119**
*↳ [@run 3.](#parser-lua-run-3)*

shell type comments


<a id="parser-lua-chk-7"></a>**7. ~/Desktop/autoodocs/lib/parser.lua:124**
*↳ [@run 3.](#parser-lua-run-3)*

double-slash comments


<a id="parser-lua-chk-8"></a>**8. ~/Desktop/autoodocs/lib/parser.lua:129**
*↳ [@run 3.](#parser-lua-run-3)*

double-dash comments


<a id="parser-lua-chk-9"></a>**9. ~/Desktop/autoodocs/lib/parser.lua:134**
*↳ [@run 3.](#parser-lua-run-3)*

C-style block opening


<a id="parser-lua-chk-10"></a>**10. ~/Desktop/autoodocs/lib/parser.lua:141**
*↳ [@run 3.](#parser-lua-run-3)*

HTML comment opening


<a id="parser-lua-chk-11"></a>**11. ~/Desktop/autoodocs/lib/parser.lua:148**
*↳ [@run 3.](#parser-lua-run-3)*

block comment continuation lines


<a id="parser-lua-chk-12"></a>**12. ~/Desktop/autoodocs/lib/parser.lua:159**
*↳ [@run 3.](#parser-lua-run-3)*

html closing


<a id="parser-lua-chk-13"></a>**13. ~/Desktop/autoodocs/lib/parser.lua:165**
*↳ [@run 3.](#parser-lua-run-3)*

triple-quote docstring styles


<a id="parser-lua-chk-14"></a>**14. ~/Desktop/autoodocs/lib/parser.lua:172**
*↳ [@run 3.](#parser-lua-run-3)*

single-quote docstring style


<a id="parser-lua-chk-15"></a>**15. ~/Desktop/autoodocs/lib/parser.lua:179**
*↳ [@run 3.](#parser-lua-run-3)*

docstring continuation lines

> no opening delimiter to strip; checks both `"""` and `'''` closers


<a id="parser-lua-chk-16"></a>**16. ~/Desktop/autoodocs/lib/parser.lua:319**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Scan untagged block comment for tags


<a id="parser-lua-chk-17"></a>**17. ~/Desktop/autoodocs/lib/parser.lua:338**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Scan untagged HTML comment for tags


<a id="parser-lua-chk-18"></a>**18. ~/Desktop/autoodocs/lib/parser.lua:371**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Scan untagged docstring for tags


<a id="parser-lua-chk-19"></a>**19. ~/Desktop/autoodocs/lib/parser.lua:396**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Detect comment style of current line

```lua
        local style = M.detect_style(line)
```

<a id="parser-lua-chk-20"></a>**20. ~/Desktop/autoodocs/lib/parser.lua:438**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Untagged block comment start - scan for tags


<a id="parser-lua-chk-21"></a>**21. ~/Desktop/autoodocs/lib/parser.lua:441**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Untagged HTML comment start


<a id="parser-lua-chk-22"></a>**22. ~/Desktop/autoodocs/lib/parser.lua:444**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Untagged double-quote docstring start


<a id="parser-lua-chk-23"></a>**23. ~/Desktop/autoodocs/lib/parser.lua:448**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Untagged single-quote docstring start


### Defines

<a id="parser-lua-def-1"></a>**1.** `~/Desktop/autoodocs/lib/parser.lua:1`

Localize functions for hot loop performance

```lua
local find   = string.find
local sub    = string.sub
local byte   = string.byte
local match  = string.match
local gmatch = string.gmatch
```

<a id="parser-lua-def-2"></a>**2.** `~/Desktop/autoodocs/lib/parser.lua:18`

Hoisted `TAGS` table avoids per-call allocation in `strip_tags`

```lua
local TAGS = {"@def", "@chk", "@run", "@err"}
```

<a id="parser-lua-def-3"></a>**3.** `~/Desktop/autoodocs/lib/parser.lua:21`

Map `!x` suffixes to admonition types

```lua
M.ADMONITIONS = {n="NOTE", t="TIP", i="IMPORTANT", w="WARNING", c="CAUTION"}
```

<a id="parser-lua-def-4"></a>**4. ~/Desktop/autoodocs/lib/parser.lua:196**
*↳ [@run 4.](#parser-lua-run-4)*

> [!NOTE]
> Bulk-read file first so `get_lang` reuses the buffer

avoids a second `open`+`read` just for shebang detection

```lua
    local f = open(filepath, "r")
    if not f then return 0 end
    local content = f:read("*a")
    f:close()
```

<a id="parser-lua-def-5"></a>**5. ~/Desktop/autoodocs/lib/parser.lua:203**
*↳ [@run 4.](#parser-lua-run-4)*

Initialize per-file state machine variables

> `get_lang` receives first line to avoid reopening the file

```lua
    local first   = match(content, "^([^\n]*)")
    local rel     = HOME and sub(filepath, 1, #HOME) == HOME and "~" .. sub(filepath, #HOME + 1) or filepath
    local lang    = get_lang(filepath, first)
    local ln      = 0
    local state   = ""
    local tag     = ""
    local start   = ""
    local text    = ""
    local nsubj   = 0
    local cap_want = 0
    local capture = 0
    local subj    = ""
    local adm     = nil
    local pending = nil
    local tag_indent = 0
```

### Runners

<a id="parser-lua-run-1"></a>**1.** `~/Desktop/autoodocs/lib/parser.lua:49`

Strip `@tag:N` and trailing digits from text

> rejoining prefix with remaining content

```lua
local function strip_tag_num(text, tag)
    local pos = find(text, tag .. ":", 1, true)
    if not pos then return text end
    local prefix = sub(text, 1, pos - 1)
    local rest = sub(text, pos + #tag + 1)
    rest = gsub(rest, "^%d+!?%a?", "")
    rest = gsub(rest, "^ ", "", 1)
    return prefix .. rest
end
```

<a id="parser-lua-run-2"></a>**2.** `~/Desktop/autoodocs/lib/parser.lua:67`

Remove `@tag`, `@tag:N`, or `@tag!x` syntax from comment text

> delegates to `strip_tag_num` for `:N` and `:N!x` variants

```lua
function M.strip_tags(text)
    for _, tag in ipairs(TAGS) do
        if find(text, tag .. ":%d") then
            return strip_tag_num(text, tag)
        end
        local epos = find(text, tag .. "!%a")
        if epos then
            local rest = sub(text, epos + #tag + 2)
            rest = gsub(rest, "^ ", "", 1)
            return sub(text, 1, epos - 1) .. rest
        end
        local spos = find(text, tag .. " ", 1, true)
        if spos then
            return sub(text, 1, spos - 1) .. sub(text, spos + #tag + 1)
        end
        local bpos = find(text, tag, 1, true)
        if bpos then
            return sub(text, 1, bpos - 1) .. sub(text, bpos + #tag)
        end
    end
    return text
end
```

<a id="parser-lua-run-3"></a>**3.** `~/Desktop/autoodocs/lib/parser.lua:116`

Strip comment delimiters and extract inner text

> for all styles including block continuations


<a id="parser-lua-run-4"></a>**4.** `~/Desktop/autoodocs/lib/parser.lua:193`

Walk one file as a line-by-line state machine

> extracting tagged comments into `records` table


<a id="parser-lua-parser-lua-run-4-1"></a>**4.1 ~/Desktop/autoodocs/lib/parser.lua:221**
*↳ [@run 4.](#parser-lua-run-4)*

> [!NOTE]
> Emit a documentation record or defer for subject capture

`lang` is passed through as-is, empty string means no fence label

```lua
    local function emit()
        if tag ~= "" and text ~= "" then
            local tr = trim(text)
            if tr ~= "" then
                if nsubj > 0 then
                    pending = {
                        tag  = tag,
                        file = rel,
                        loc  = rel .. ":" .. start,
                        text = tr,
                        lang = lang,
                        adm  = adm,
                        indent = tag_indent,
                    }
                    cap_want = nsubj
                    subj = ""
                else
                    records[#records + 1] = {
                        tag  = tag,
                        file = rel,
                        loc  = rel .. ":" .. start,
                        text = tr,
                        lang = lang,
                        subj = "",
                        adm  = adm,
                        indent = tag_indent,
                    }
                end
            end
        end
        state = ""
        tag   = ""
        start = ""
        text  = ""
        nsubj = 0
        adm   = nil
    end
```

<a id="parser-lua-parser-lua-run-4-2"></a>**4.2 ~/Desktop/autoodocs/lib/parser.lua:261**
*↳ [@run 4.](#parser-lua-run-4)*

Flush deferred record with captured `subj` lines

```lua
    local function flush_pending()
        if pending then
            pending.subj = subj
            records[#records + 1] = pending
            pending = nil
            subj    = ""
            capture = 0
        end
    end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-1"></a>**4.2.1 ~/Desktop/autoodocs/lib/parser.lua:281**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Subject line capture mode

```lua
        if capture > 0 then
            if subj ~= "" then
                subj = subj .. US .. line
            else
                subj = line
            end
            capture = capture - 1
            if capture == 0 then flush_pending() end
            goto continue
        end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-2"></a>**4.2.2 ~/Desktop/autoodocs/lib/parser.lua:293**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Accumulate C-style block comment with tag

```lua
        if state == "cblock" then
            if find(line, "*/", 1, true) then
                local sc = M.strip_comment(line, "cblock_cont")
                if sc ~= "" then text = text .. US .. sc end
                emit()
            else
                local sc = M.strip_comment(line, "cblock_cont")
                text = text .. US .. sc
            end
            goto continue
        end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-3"></a>**4.2.3 ~/Desktop/autoodocs/lib/parser.lua:306**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Accumulate HTML comment with tag

```lua
        if state == "html" then
            if find(line, "-->", 1, true) then
                local sc = M.strip_comment(line, "html_cont")
                if sc ~= "" then text = text .. US .. sc end
                emit()
            else
                local sc = M.strip_comment(line, "html_cont")
                text = text .. US .. sc
            end
            goto continue
        end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-4"></a>**4.2.4 ~/Desktop/autoodocs/lib/parser.lua:357**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Accumulate docstring with tag

```lua
        if state == "dquote" or state == "squote" then
            local close = (state == "dquote") and '"""' or "'''"
            if find(line, close, 1, true) then
                local sc = M.strip_comment(line, "docstring_cont")
                if sc ~= "" then text = text .. US .. sc end
                emit()
            else
                local sc = M.strip_comment(line, "docstring_cont")
                text = text .. US .. sc
            end
            goto continue
        end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-5"></a>**4.2.5 ~/Desktop/autoodocs/lib/parser.lua:399**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Continue or close existing single-line comment block

```lua
        if state ~= "" then
            if style == state then
                if M.has_tag(line) then
                    emit()
                else
                    local sc = M.strip_comment(line, style)
                    text = text .. US .. sc
                    goto continue
                end
            else
                emit()
            end
        end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-6"></a>**4.2.6 ~/Desktop/autoodocs/lib/parser.lua:414**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Dispatch new tagged comment by style

```lua
        if M.has_tag(line) and style ~= "none" then
            tag   = M.get_tag(line)
            start = tostring(ln)
            local ti = 1; while byte(line,ti) == 32 or byte(line,ti) == 9 do ti = ti+1 end; tag_indent = ti-1
            local sc = M.strip_comment(line, style)
            nsubj = M.get_subject_count(sc)
            adm   = M.get_admonition(sc)
            text  = M.strip_tags(sc)

            if style == "hash" or style == "dslash" or style == "ddash" then
                state = style
            elseif style == "cblock" then
                if find(line, "*/", 1, true) then emit() else state = "cblock" end
            elseif style == "html" then
                if find(line, "-->", 1, true) then emit() else state = "html" end
            elseif style == "dquote" then
                local rest = match(line, '"""(.*)')
                if rest and find(rest, '"""', 1, true) then emit() else state = "dquote" end
            elseif style == "squote" then
                local rest = match(line, "'''(.*)")
                if rest and find(rest, "'''", 1, true) then emit() else state = "squote" end
            end
```

<a id="parser-lua-parser-lua-parser-lua-run-4-2-7"></a>**4.2.7 ~/Desktop/autoodocs/lib/parser.lua:454**
*↳ [@run 4.2](#parser-lua-parser-lua-run-4-2)*

Begin subject capture if waiting and hit a code line

```lua
        if cap_want > 0 and style == "none" then
            capture  = cap_want
            cap_want = 0
            subj     = line
            capture  = capture - 1
            if capture == 0 then flush_pending() end
        end
```

---

## <a id="utils-lua"></a>utils.lua

`~/Desktop/autoodocs/lib/utils.lua`

### Checks

<a id="utils-lua-chk-1"></a>**1.** `~/Desktop/autoodocs/lib/utils.lua:61`

Classify file language via extension or shebang

> accepts `first_line` to avoid reopening the file

```lua
function M.get_lang(filepath, first_line)
    local ext = match(filepath, "%.([^%.]+)$")
    if ext and M.ext_map[ext] then return M.ext_map[ext] end
    if first_line and sub(first_line, 1, 3) == "#!/" then
        for _, pair in ipairs(M.shebang_map) do
            if find(first_line, pair[1], 1, true) then
                return pair[2]
            end
        end
    end
    return ""
end
```

### Defines

<a id="utils-lua-def-1"></a>**1.** `~/Desktop/autoodocs/lib/utils.lua:1`

Localize `string.*`, `table.*`, and `io.*` functions

> bypasses metatable and global lookups in the hot loop

```lua
local find   = string.find
local sub    = string.sub
local byte   = string.byte
local match  = string.match
local gsub   = string.gsub
local open   = io.open

local M = {}

```

<a id="utils-lua-def-2"></a>**2.** `~/Desktop/autoodocs/lib/utils.lua:12`

> [!NOTE]
> Shell-escape a string for safe interpolation into `io.popen`

prevents breakage from paths containing `"`, `$()`, or backticks

```lua
function M.shell_quote(s)
    return "'" .. gsub(s, "'", "'\\''") .. "'"
end
```

<a id="utils-lua-def-3"></a>**3.** `~/Desktop/autoodocs/lib/utils.lua:41`

Map file extension to fenced code block language

```lua
M.ext_map = {
    sh="sh", bash="sh", py="python",
    js="javascript", mjs="javascript", cjs="javascript",
    ts="typescript", mts="typescript", cts="typescript",
    jsx="jsx", tsx="tsx", rb="ruby", go="go", rs="rust",
    c="c", h="c", cpp="cpp", hpp="cpp", cc="cpp", cxx="cpp",
    java="java", cs="csharp", swift="swift", kt="kotlin", kts="kotlin",
    lua="lua", sql="sql", html="html", htm="html", css="css", xml="xml",
    yaml="yaml", yml="yaml", toml="toml", json="json",
    php="php", pl="perl", pm="perl", zig="zig",
    hs="haskell", ex="elixir", exs="elixir", erl="erlang",
}
```

<a id="utils-lua-def-4"></a>**4.** `~/Desktop/autoodocs/lib/utils.lua:55`

Map shebang interpreters to fenced code block language

```lua
M.shebang_map = {
    {"python", "python"}, {"node", "javascript"}, {"ruby", "ruby"},
    {"perl", "perl"}, {"lua", "lua"}, {"php", "php"}, {"sh", "sh"},
}
```

### Runners

<a id="utils-lua-run-1"></a>**1.** `~/Desktop/autoodocs/lib/utils.lua:18`

Strip leading spaces and tabs via byte scan

> returns original string when no trimming needed

```lua
function M.trim_lead(s)
    local i = 1
    while byte(s, i) == 32 or byte(s, i) == 9 do i = i + 1 end
    if i == 1 then return s end
    return sub(s, i)
end
```

<a id="utils-lua-run-2"></a>**2.** `~/Desktop/autoodocs/lib/utils.lua:27`

Strip trailing spaces and tabs via byte scan

> returns original string when no trimming needed

```lua
function M.trim_trail(s)
    local i = #s
    while i > 0 and (byte(s, i) == 32 or byte(s, i) == 9) do i = i - 1 end
    if i == #s then return s end
    return sub(s, 1, i)
end
```

<a id="utils-lua-run-3"></a>**3.** `~/Desktop/autoodocs/lib/utils.lua:36`

Trim both ends via `trim_lead` and `trim_trail`

```lua
function M.trim(s)
    return M.trim_trail(M.trim_lead(s))
end
```

---

## <a id="render-lua"></a>render.lua

`~/Desktop/autoodocs/lib/render.lua`

### Defines

<a id="render-lua-def-1"></a>**1.** `~/Desktop/autoodocs/lib/render.lua:1`

Localize functions for performance

```lua
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
```

<a id="render-lua-def-2"></a>**2.** `~/Desktop/autoodocs/lib/render.lua:8`

Import utils for trim

```lua
local utils = require("lib.utils")
local trim = utils.trim
```

<a id="render-lua-def-3"></a>**3.** `~/Desktop/autoodocs/lib/render.lua:12`

Module table

```lua
local M = {}
```

<a id="render-lua-def-4"></a>**4.** `~/Desktop/autoodocs/lib/render.lua:15`

Map tag prefixes to anchor slugs and section titles

```lua
M.TAG_SEC   = {CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}
```

### Runners

<a id="render-lua-run-1"></a>**1.** `~/Desktop/autoodocs/lib/render.lua:20`

Generate a slug from a file path for anchors


<a id="render-lua-run-2"></a>**2.** `~/Desktop/autoodocs/lib/render.lua:28`

Render a single entry


<a id="render-lua-run-3"></a>**3.** `~/Desktop/autoodocs/lib/render.lua:82`

Render records organized by file with TOC


<a id="render-lua-run-4"></a>**4.** `~/Desktop/autoodocs/lib/render.lua:128`

Group records by file and assign indices


---

## <a id="autodocs-lua"></a>autodocs.lua

`~/Desktop/autoodocs/autodocs.lua`

### Checks

<a id="autodocs-lua-chk-1"></a>**1.** `~/Desktop/autoodocs/autodocs.lua:2`

`-s` outputs extra stats


<a id="autodocs-lua-chk-2"></a>**2. ~/Desktop/autoodocs/autodocs.lua:84**
*↳ [@run 1.](#autodocs-lua-run-1)*

Verify tagged files were discovered

```lua
    if #files == 0 then
```

<a id="autodocs-lua-chk-3"></a>**3. ~/Desktop/autoodocs/autodocs.lua:105**
*↳ [@run 1.](#autodocs-lua-run-1)*

Verify extraction produced results

```lua
    if #records == 0 then
```

<a id="autodocs-lua-chk-4"></a>**4. ~/Desktop/autoodocs/autodocs.lua:119**
*↳ [@run 1.](#autodocs-lua-run-1)*

Render and compare against existing output

> skip write if content is unchanged

```lua
    local markdown = render.render_markdown(by_file, file_order)
    local ef = open(OUTPUT, "r")
    if ef then
        local existing = ef:read("*a")
        ef:close()
        if existing == markdown then
            io.stderr:write(fmt("autodocs: %s unchanged\n", OUTPUT))
            return
        end
    end
```

### Defines

<a id="autodocs-lua-def-1"></a>**1.** `~/Desktop/autoodocs/autodocs.lua:10`

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

<a id="autodocs-lua-def-2"></a>**2.** `~/Desktop/autoodocs/autodocs.lua:31`

Localize functions and load libraries

```lua
local match  = string.match
local gsub   = string.gsub
local sub    = string.sub
local fmt    = string.format
```

<a id="autodocs-lua-def-3"></a>**3.** `~/Desktop/autoodocs/autodocs.lua:42`

Parse CLI args with defaults

> strip trailing slash, resolve absolute path via `/proc/self/environ`

> `US` separates multi-line text within record fields

```lua
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

```

<a id="autodocs-lua-def-4"></a>**4.** `~/Desktop/autoodocs/autodocs.lua:58`

Global state for collected records and line count

```lua
local records = {}
local total_input = 0
```

### Runners

<a id="autodocs-lua-run-1"></a>**1.** `~/Desktop/autoodocs/autodocs.lua:62`

Main function

```lua
local function main()
```

<a id="autodocs-lua-autodocs-lua-run-1-1"></a>**1.1 ~/Desktop/autoodocs/autodocs.lua:64**
*↳ [@run 1.](#autodocs-lua-run-1)*

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
        'grep -rl -I --exclude-dir=.git --exclude="readme*" --exclude="index.html" %s -e "@def" -e "@chk" -e "@run" -e "@err" %s 2>/dev/null',
        gi, utils.shell_quote(SCAN_DIR)
    )
    local pipe = io.popen(cmd)
    local files = {}
    for line in pipe:lines() do
        files[#files + 1] = line
    end
    pipe:close()
```

<a id="autodocs-lua-autodocs-lua-run-1-2"></a>**1.2 ~/Desktop/autoodocs/autodocs.lua:98**
*↳ [@run 1.](#autodocs-lua-run-1)*

Process all discovered files into intermediate `records`

```lua
    for _, fp in ipairs(files) do
        if not match(fp, "/" .. out_base_escaped .. "$") then
            total_input = total_input + parser.process_file(fp, records, HOME, US)
        end
    end
```

<a id="autodocs-lua-autodocs-lua-run-1-3"></a>**1.3 ~/Desktop/autoodocs/autodocs.lua:116**
*↳ [@run 1.](#autodocs-lua-run-1)*

Group and index records by file

```lua
    local by_file, file_order = render.group_records(records)
```

<a id="autodocs-lua-autodocs-lua-run-1-4"></a>**1.4 ~/Desktop/autoodocs/autodocs.lua:132**
*↳ [@run 1.](#autodocs-lua-run-1)*

Write output and report ratio

> wraps across two lines so `:N` count must include the continuation

```lua
    local f = open(OUTPUT, "w")
    f:write(markdown)
    f:close()
    local ol = select(2, gsub(markdown, "\n", "")) + 1
    io.stderr:write(fmt("autodocs: wrote %s (%d/%d = %d%%)\n",
        OUTPUT, ol, total_input, total_input > 0 and math.floor(ol * 100 / total_input) or 0))
```

<a id="autodocs-lua-autodocs-lua-run-1-5"></a>**1.5 ~/Desktop/autoodocs/autodocs.lua:141**
*↳ [@run 1.](#autodocs-lua-run-1)*

Run `stats.awk` on the output if `-s` flag is set

```lua
    if STATS then
        local script_dir = match(arg[0], "^(.*/)") or "./"
        local stats_awk = script_dir .. "stats.awk"
        local sf = open(stats_awk, "r")
        if sf then
            sf:close()
            os.execute(fmt("awk -f %s %s >&2", utils.shell_quote(stats_awk), utils.shell_quote(OUTPUT)))
        end
    end
```

<a id="autodocs-lua-run-2"></a>**2.** `~/Desktop/autoodocs/autodocs.lua:153`

Entry point

```lua
main()
```

### Errors

<a id="autodocs-lua-err-1"></a>**1. ~/Desktop/autoodocs/autodocs.lua:86**
*↳ [@chk 2.](#autodocs-lua-chk-2)*

Handle missing tagged files

> with empty output and `stderr` warning

```lua
        local f = open(OUTPUT, "w")
        f:write("No tagged documentation found.\n")
        f:close()
        io.stderr:write(fmt("autodocs: no tags found under %s\n", SCAN_DIR))
        return
```

<a id="autodocs-lua-err-2"></a>**2. ~/Desktop/autoodocs/autodocs.lua:107**
*↳ [@chk 3.](#autodocs-lua-chk-3)*

Handle extraction failure

> with empty output and `stderr` warning

```lua
        local f = open(OUTPUT, "w")
        f:write("No tagged documentation found.\n")
        f:close()
        io.stderr:write(fmt("autodocs: tags found but no extractable docs under %s\n", SCAN_DIR))
        return
```

---

