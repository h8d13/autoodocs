# parser.lua

`~/Desktop/autoodocs/lib/parser.lua`

## Contents

- [Checks](#chk)
- [Defines](#def)
- [Runners](#run)

## <a id="chk"></a>Checks

<a id="chk-1"></a>**1.** `~/Desktop/autoodocs/lib/parser.lua:24`

Test whether a line contains any documentation tag

> early `@` check short-circuits lines with no tags

```lua
function M.has_tag(line)
    if not find(line, "@", 1, true) then return nil end
    return find(line, "@def", 1, true) or find(line, "@chk", 1, true) or
           find(line, "@run", 1, true) or find(line, "@err", 1, true)
end
```

<a id="chk-2"></a>**2.** `~/Desktop/autoodocs/lib/parser.lua:32`

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

<a id="chk-3"></a>**3.** `~/Desktop/autoodocs/lib/parser.lua:41`

Extract the subject line count from `@tag:N` syntax

> using pattern capture after the colon

```lua
function M.get_subject_count(text)
    local n = match(text, "@def:(%d+)") or match(text, "@chk:(%d+)") or
              match(text, "@run:(%d+)") or match(text, "@err:(%d+)")
    return tonumber(n) or 0
end
```

<a id="chk-4"></a>**4.** `~/Desktop/autoodocs/lib/parser.lua:61`

Extract `!x` admonition suffix from tag syntax

```lua
function M.get_admonition(text)
    local code = match(text, "@%a+:?%d*!(%a)")
    if code then return M.ADMONITIONS[code] end
end
```

<a id="chk-5"></a>**5.** `~/Desktop/autoodocs/lib/parser.lua:92`

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

<a id="chk-6"></a>**6. ~/Desktop/autoodocs/lib/parser.lua:119**
*↳ [@run 3.](#run-3)*

shell type comments


<a id="chk-7"></a>**7. ~/Desktop/autoodocs/lib/parser.lua:124**
*↳ [@run 3.](#run-3)*

double-slash comments


<a id="chk-8"></a>**8. ~/Desktop/autoodocs/lib/parser.lua:129**
*↳ [@run 3.](#run-3)*

double-dash comments


<a id="chk-9"></a>**9. ~/Desktop/autoodocs/lib/parser.lua:134**
*↳ [@run 3.](#run-3)*

C-style block opening


<a id="chk-10"></a>**10. ~/Desktop/autoodocs/lib/parser.lua:141**
*↳ [@run 3.](#run-3)*

HTML comment opening


<a id="chk-11"></a>**11. ~/Desktop/autoodocs/lib/parser.lua:148**
*↳ [@run 3.](#run-3)*

block comment continuation lines


<a id="chk-12"></a>**12. ~/Desktop/autoodocs/lib/parser.lua:159**
*↳ [@run 3.](#run-3)*

html closing


<a id="chk-13"></a>**13. ~/Desktop/autoodocs/lib/parser.lua:165**
*↳ [@run 3.](#run-3)*

triple-quote docstring styles


<a id="chk-14"></a>**14. ~/Desktop/autoodocs/lib/parser.lua:172**
*↳ [@run 3.](#run-3)*

single-quote docstring style


<a id="chk-15"></a>**15. ~/Desktop/autoodocs/lib/parser.lua:179**
*↳ [@run 3.](#run-3)*

docstring continuation lines

> no opening delimiter to strip; checks both `"""` and `'''` closers


<a id="chk-16"></a>**16. ~/Desktop/autoodocs/lib/parser.lua:319**
*↳ [@run 4.2](#run-4-2)*

Scan untagged block comment for tags


<a id="chk-17"></a>**17. ~/Desktop/autoodocs/lib/parser.lua:338**
*↳ [@run 4.2](#run-4-2)*

Scan untagged HTML comment for tags


<a id="chk-18"></a>**18. ~/Desktop/autoodocs/lib/parser.lua:371**
*↳ [@run 4.2](#run-4-2)*

Scan untagged docstring for tags


<a id="chk-19"></a>**19. ~/Desktop/autoodocs/lib/parser.lua:396**
*↳ [@run 4.2](#run-4-2)*

Detect comment style of current line

```lua
        local style = M.detect_style(line)
```

<a id="chk-20"></a>**20. ~/Desktop/autoodocs/lib/parser.lua:438**
*↳ [@run 4.2](#run-4-2)*

Untagged block comment start - scan for tags


<a id="chk-21"></a>**21. ~/Desktop/autoodocs/lib/parser.lua:441**
*↳ [@run 4.2](#run-4-2)*

Untagged HTML comment start


<a id="chk-22"></a>**22. ~/Desktop/autoodocs/lib/parser.lua:444**
*↳ [@run 4.2](#run-4-2)*

Untagged double-quote docstring start


<a id="chk-23"></a>**23. ~/Desktop/autoodocs/lib/parser.lua:448**
*↳ [@run 4.2](#run-4-2)*

Untagged single-quote docstring start


## <a id="def"></a>Defines

<a id="def-1"></a>**1.** `~/Desktop/autoodocs/lib/parser.lua:1`

Localize functions for hot loop performance

```lua
local find   = string.find
local sub    = string.sub
local byte   = string.byte
local match  = string.match
local gmatch = string.gmatch
```

<a id="def-2"></a>**2.** `~/Desktop/autoodocs/lib/parser.lua:18`

Hoisted `TAGS` table avoids per-call allocation in `strip_tags`

```lua
local TAGS = {"@def", "@chk", "@run", "@err"}
```

<a id="def-3"></a>**3.** `~/Desktop/autoodocs/lib/parser.lua:21`

Map `!x` suffixes to admonition types

```lua
M.ADMONITIONS = {n="NOTE", t="TIP", i="IMPORTANT", w="WARNING", c="CAUTION"}
```

<a id="def-4"></a>**4. ~/Desktop/autoodocs/lib/parser.lua:196**
*↳ [@run 4.](#run-4)*

> [!NOTE]
> Bulk-read file first so `get_lang` reuses the buffer

avoids a second `open`+`read` just for shebang detection

```lua
    local f = open(filepath, "r")
    if not f then return 0 end
    local content = f:read("*a")
    f:close()
```

<a id="def-5"></a>**5. ~/Desktop/autoodocs/lib/parser.lua:203**
*↳ [@run 4.](#run-4)*

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

## <a id="run"></a>Runners

<a id="run-1"></a>**1.** `~/Desktop/autoodocs/lib/parser.lua:49`

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

<a id="run-2"></a>**2.** `~/Desktop/autoodocs/lib/parser.lua:67`

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

<a id="run-3"></a>**3.** `~/Desktop/autoodocs/lib/parser.lua:116`

Strip comment delimiters and extract inner text

> for all styles including block continuations


<a id="run-4"></a>**4.** `~/Desktop/autoodocs/lib/parser.lua:193`

Walk one file as a line-by-line state machine

> extracting tagged comments into `records` table


<a id="run-4-1"></a>**4.1 ~/Desktop/autoodocs/lib/parser.lua:221**
*↳ [@run 4.](#run-4)*

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

<a id="run-4-2"></a>**4.2 ~/Desktop/autoodocs/lib/parser.lua:261**
*↳ [@run 4.](#run-4)*

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

<a id="run-4-2-1"></a>**4.2.1 ~/Desktop/autoodocs/lib/parser.lua:281**
*↳ [@run 4.2](#run-4-2)*

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

<a id="run-4-2-2"></a>**4.2.2 ~/Desktop/autoodocs/lib/parser.lua:293**
*↳ [@run 4.2](#run-4-2)*

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

<a id="run-4-2-3"></a>**4.2.3 ~/Desktop/autoodocs/lib/parser.lua:306**
*↳ [@run 4.2](#run-4-2)*

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

<a id="run-4-2-4"></a>**4.2.4 ~/Desktop/autoodocs/lib/parser.lua:357**
*↳ [@run 4.2](#run-4-2)*

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

<a id="run-4-2-5"></a>**4.2.5 ~/Desktop/autoodocs/lib/parser.lua:399**
*↳ [@run 4.2](#run-4-2)*

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

<a id="run-4-2-6"></a>**4.2.6 ~/Desktop/autoodocs/lib/parser.lua:414**
*↳ [@run 4.2](#run-4-2)*

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

<a id="run-4-2-7"></a>**4.2.7 ~/Desktop/autoodocs/lib/parser.lua:454**
*↳ [@run 4.2](#run-4-2)*

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

