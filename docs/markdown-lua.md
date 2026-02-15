# markdown.lua

`~/Desktop/autoodocs/markdown.lua`

Markdown to HTML converter with GitHub-style callouts and TOC generation

Mostly stolen from *↗ [speedata](https://github.com/speedata/luamarkdown)* with minor modifications for parsers/build.

## <a id="chk"></a>Checks

### <a id="chk-1"></a>1. Lua 5.1/5.2 compatibility

`~/Desktop/autoodocs/markdown.lua:69`

```lua
table.unpack = table.unpack or unpack
```

### <a id="chk-2"></a>2. Returns true if line is a ruler of repeated characters

`~/Desktop/autoodocs/markdown.lua:338`

The line must contain at least three char characters and contain only spaces and

> char characters.

```lua
local function is_ruler_of(line, char)
    if not line:match("^[ %" .. char .. "]*$") then return false end
    if not line:match("%" .. char .. ".*%" .. char .. ".*%" .. char) then return false end
    return true
end
```

### <a id="chk-3"></a>3. Classify block-level formatting in a line

`~/Desktop/autoodocs/markdown.lua:347`

```lua
local function classify(line)
    local info = {line = line, text = line}

    if line:match("^    ") then
        info.type = "indented"
        info.outdented = line:sub(5)
        return info
    end

    for _,c in ipairs({'*', '-', '_', '='}) do
        if is_ruler_of(line, c) then
            info.type = "ruler"
            info.ruler_char = c
            return info
        end
    end

    if line == "" then
        info.type = "blank"
        return info
    end

    if line:match("^(#+)[ \t]*(.-)[ \t]*#*[ \t]*$") then
        local m1, m2 = line:match("^(#+)[ \t]*(.-)[ \t]*#*[ \t]*$")
        info.type = "header"
        info.level = m1:len()
        info.text = m2
        return info
    end

    if line:match("^ ? ? ?(%d+)%.[ \t]+(.+)") then
        local number, text = line:match("^ ? ? ?(%d+)%.[ \t]+(.+)")
        info.type = "list_item"
        info.list_type = "numeric"
        info.number = 0 + number
        info.text = text
        return info
    end

    if line:match("^ ? ? ?([%*%+%-])[ \t]+(.+)") then
        local bullet, text = line:match("^ ? ? ?([%*%+%-])[ \t]+(.+)")
        info.type = "list_item"
        info.list_type = "bullet"
        info.bullet = bullet
        info.text= text
        return info
    end

    if line:match("^>[ \t]?(.*)") then
        info.type = "blockquote"
        info.text = line:match("^>[ \t]?(.*)")
        return info
    end

    if is_protected(line) then
        info.type = "raw"
        info.html = unprotect(line)
        return info
    end

    info.type = "normal"
    return info
end
```

### <a id="chk-4"></a>4. Returns target="_blank" attribute for external URLs

`~/Desktop/autoodocs/markdown.lua:922`

```lua
local function external(url)
    if url:match("^https?://") or url:match("^ftp:") then return ' target="_blank"' end
    return ""
end
```

## <a id="def"></a>Defines

### <a id="def-1"></a>1. Forward declarations for mutually recursive functions

`~/Desktop/autoodocs/markdown.lua:72`

```lua
local span_transform, encode_backslash_escapes, block_transform, blocks_to_html
```

### <a id="def-2"></a>2. Map values in table through function f

`~/Desktop/autoodocs/markdown.lua:79`

```lua
local function map(t, f)
    local out = {}
    for k,v in pairs(t) do out[k] = f(v,k) end
    return out
end
```

### <a id="def-3"></a>3. Identity function, useful as a placeholder

`~/Desktop/autoodocs/markdown.lua:86`

```lua
local function identity(text) return text end
```

### <a id="def-4"></a>4. Functional style ternary (no short circuit)

`~/Desktop/autoodocs/markdown.lua:89`

```lua
local function iff(t, a, b) if t then return a else return b end end
```

### <a id="def-5"></a>5. Hash data into unique alphanumeric strings

`~/Desktop/autoodocs/markdown.lua:203`

> [!NOTE]
> not cryptographic - used to protect parts from further processing

```lua
local HASH = {
    -- Has the hash been inited.
    inited = false,

    -- The unique string prepended to all hash values. This is to ensure
    -- that hash values do not accidently coincide with an actual existing
    -- string in the document.
    identifier = "",

    -- Counter that counts up for each new hash instance.
    counter = 0,

    -- Hash table.
    table = {}
}
```

### <a id="def-6"></a>6. Protect document parts from modification

`~/Desktop/autoodocs/markdown.lua:255`

> [!NOTE]
> saved in table for later unprotection

```lua
local PD = {
    -- Saved blocks that have been converted
    blocks = {},

    -- Block level tags that will be protected
    tags = {"p", "div", "h1", "h2", "h3", "h4", "h5", "h6", "blockquote",
    "pre", "table", "dl", "ol", "ul", "script", "noscript", "form", "fieldset",
    "iframe", "math", "ins", "del"}
}
```

### <a id="def-7"></a>7. Characters with special markdown meaning needing escape

`~/Desktop/autoodocs/markdown.lua:778`

```lua
escape_chars = "'\\`*_{}[]()>#+-.!'"
escape_table = {}
```

## <a id="run"></a>Runners

### <a id="run-1"></a>1. Split text into array of lines by separator

`~/Desktop/autoodocs/markdown.lua:92`

```lua
local function split(text, sep)
    sep = sep or "\n"
    local lines = {}
    local pos = 1
    while true do
        local b,e = text:find(sep, pos)
        if not b then table.insert(lines, text:sub(pos)) break end
        table.insert(lines, text:sub(pos, b-1))
        pos = e + 1
    end
    return lines
end
```

### <a id="run-2"></a>2. Block-level text transforms working with arrays of lines

`~/Desktop/autoodocs/markdown.lua:336`


### <a id="run-3"></a>3. Convert normal + ruler lines to header entries

`~/Desktop/autoodocs/markdown.lua:412`

```lua
local function headers(array)
    local i = 1
    while i <= #array - 1 do
        if array[i].type  == "normal" and array[i+1].type == "ruler" and
            (array[i+1].ruler_char == "-" or array[i+1].ruler_char == "=") then
            local info = {line = array[i].line}
            info.text = info.line
            info.type = "header"
            info.level = iff(array[i+1].ruler_char == "=", 1, 2)
            table.remove(array, i+1)
            array[i] = info
        end
        i = i + 1
    end
    return array
end
```

### <a id="run-4"></a>4. Convert list blocks to protected HTML

`~/Desktop/autoodocs/markdown.lua:430`

```lua
local function lists(array, sublist)
    local function process_list(arr)
        local function any_blanks(arr)
            for i = 1, #arr do
                if arr[i].type == "blank" then return true end
            end
            return false
        end

        local function split_list_items(arr)
            local acc = {arr[1]}
            local res = {}
            for i=2,#arr do
                if arr[i].type == "list_item" then
                    table.insert(res, acc)
                    acc = {arr[i]}
                else
                    table.insert(acc, arr[i])
                end
            end
            table.insert(res, acc)
            return res
        end

        local function process_list_item(lines, block)
            while lines[#lines].type == "blank" do
                table.remove(lines)
            end

            local itemtext = lines[1].text
            for i=2,#lines do
                itemtext = itemtext .. "\n" .. outdent(lines[i].line)
            end
            if block then
                itemtext = block_transform(itemtext, true)
                if not itemtext:find("<pre>") then itemtext = indent(itemtext) end
                return "    <li>" .. itemtext .. "</li>"
            else
                local lines = split(itemtext)
                lines = map(lines, classify)
                lines = lists(lines, true)
                lines = blocks_to_html(lines, true)
                itemtext = table.concat(lines, "\n")
                if not itemtext:find("<pre>") then itemtext = indent(itemtext) end
                return "    <li>" .. itemtext .. "</li>"
            end
        end

        local block_list = any_blanks(arr)
        local items = split_list_items(arr)
        local out = ""
        for _, item in ipairs(items) do
            out = out .. process_list_item(item, block_list) .. "\n"
        end
        if arr[1].list_type == "numeric" then
            return "<ol>\n" .. out .. "</ol>"
        else
            return "<ul>\n" .. out .. "</ul>"
        end
    end

    -- Finds the range of lines composing the first list in the array. A list
    -- starts with (^ list_item) or (blank list_item) and ends with
    -- (blank* $) or (blank normal).
    --
    -- A sublist can start with just (list_item) does not need a blank...
    local function find_list(array, sublist)
        local function find_list_start(array, sublist)
            if array[1].type == "list_item" then return 1 end
            if sublist then
                for i = 1,#array do
                    if array[i].type == "list_item" then return i end
                end
            else
                for i = 1, #array-1 do
                    if array[i].type == "blank" and array[i+1].type == "list_item" then
                        return i+1
                    end
                end
            end
            return nil
        end
        local function find_list_end(array, start)
            local pos = #array
            for i = start, #array-1 do
                if array[i].type == "blank" and array[i+1].type ~= "list_item"
                    and array[i+1].type ~= "indented" and array[i+1].type ~= "blank" then
                    pos = i-1
                    break
                end
            end
            while pos > start and array[pos].type == "blank" do
                pos = pos - 1
            end
            return pos
        end

        local start = find_list_start(array, sublist)
        if not start then return nil end
        return start, find_list_end(array, start)
    end

    while true do
        local start, stop = find_list(array, sublist)
        if not start then break end
        local text = process_list(splice(array, start, stop))
        local info = {
            line = text,
            type = "raw",
            html = text
        }
        array = splice(array, start, stop, {info})
    end

    -- Convert any remaining list items to normal
    for _,line in ipairs(array) do
        if line.type == "list_item" then line.type = "normal" end
    end

    return array
end
```

### <a id="run-5"></a>5. Convert blockquote markers with GitHub callout support

`~/Desktop/autoodocs/markdown.lua:553`

```lua
local function blockquotes(lines)
    local function find_blockquote(lines)
        local start
        for i,line in ipairs(lines) do
            if line.type == "blockquote" then
                start = i
                break
            end
        end
        if not start then return nil end

        local stop = #lines
        for i = start+1, #lines do
            if lines[i].type == "blank" or lines[i].type == "blockquote" then
            elseif lines[i].type == "normal" then
                if lines[i-1].type == "blank" then stop = i-1 break end
            else
                stop = i-1 break
            end
        end
        while lines[stop].type == "blank" do stop = stop - 1 end
        return start, stop
    end

    local function process_blockquote(lines)
        local raw = lines[1].text
        for i = 2,#lines do
            raw = raw .. "\n" .. lines[i].text
        end

        -- Check for GitHub-style callouts [!NOTE], [!TIP], [!IMPORTANT], [!WARNING], [!CAUTION]
        local callout_type = raw:match("^%[!(%u+)%]")
        if callout_type then
            raw = raw:gsub("^%[!%u+%]%s*", "") -- remove the callout marker
            local bt = block_transform(raw)
            if not bt:find("<pre>") then bt = indent(bt) end
            local ctype = callout_type:lower()
            return '<div class="callout callout-' .. ctype .. '">\n    <div class="callout-title">' ..
                callout_type .. '</div>\n    ' .. bt .. "\n</div>"
        end

        local bt = block_transform(raw)
        if not bt:find("<pre>") then bt = indent(bt) end
        return "<blockquote>\n    " .. bt ..
            "\n</blockquote>"
    end

    while true do
        local start, stop = find_blockquote(lines)
        if not start then break end
        local text = process_blockquote(splice(lines, start, stop))
        local info = {
            line = text,
            type = "raw",
            html = text
        }
        lines = splice(lines, start, stop, {info})
    end
    return lines
end
```

### <a id="run-6"></a>6. Convert fenced code blocks with language hints

`~/Desktop/autoodocs/markdown.lua:615`

```lua
local function fenced_codeblocks(lines)
    local function find_fenced_codeblock(lines)
        local start, fence_char, fence_len, lang
        for i, line in ipairs(lines) do
            local fc, rest = line.line:match("^(```+)(.*)")
            if not fc then
                fc, rest = line.line:match("^(~~~+)(.*)")
            end
            if fc then
                start = i
                fence_char = fc:sub(1,1)
                fence_len = #fc
                lang = rest:match("^%s*(%S*)") or ""
                break
            end
        end
        if not start then return nil end

        -- Find closing fence (must be at least as long, same char, nothing else on line)
        local stop
        for i = start + 1, #lines do
            local fc = lines[i].line:match("^(" .. fence_char:rep(fence_len) .. "+)%s*$")
            if fc then
                stop = i
                break
            end
        end
        if not stop then return nil end
        return start, stop, lang
    end

    local function process_fenced_codeblock(lines, start, stop, lang)
        local code_lines = {}
        for i = start + 1, stop - 1 do
            table.insert(code_lines, detab(encode_code(lines[i].line)))
        end
        local raw = table.concat(code_lines, "\n")
        if lang and lang ~= "" then
            return '<pre><code class="language-' .. lang .. '">' .. raw .. "\n</code></pre>"
        else
            return "<pre><code>" .. raw .. "\n</code></pre>"
        end
    end

    while true do
        local start, stop, lang = find_fenced_codeblock(lines)
        if not start then break end
        local text = process_fenced_codeblock(lines, start, stop, lang)
        local info = {
            line = text,
            type = "raw",
            html = text
        }
        lines = splice(lines, start, stop, {info})
    end
    return lines
end
```

### <a id="run-7"></a>7. Span-level text transforms for inline formatting

`~/Desktop/autoodocs/markdown.lua:776`


### <a id="run-8"></a>8. Normalize line endings, tabs, and whitespace

`~/Desktop/autoodocs/markdown.lua:1078`

```lua
local function cleanup(text)
    -- Standardize line endings
    text = text:gsub("\r\n", "\n")  -- DOS to UNIX
    text = text:gsub("\r", "\n")    -- Mac to UNIX

    -- Convert all tabs to spaces
    text = detab(text)

    -- Strip lines with only spaces and tabs
    while true do
        local subs
        text, subs = text:gsub("\n[ \t]+\n", "\n\n")
        if subs == 0 then break end
    end

    return "\n" .. text .. "\n"
end
```

### <a id="run-9"></a>9. Main markdown processing pipeline

`~/Desktop/autoodocs/markdown.lua:1123`

```lua
local function markdown(text)
    init_hash(text)
    init_escape_table()

    text = cleanup(text)
    text = protect(text)
    text, link_database = strip_link_definitions(text)
    text = block_transform(text)
    text = unescape_special_chars(text)
    return text
end
```

### <a id="run-10"></a>10. CLI handler with HTML wrapping and TOC generation

`~/Desktop/autoodocs/markdown.lua:1226`

```lua
local function run_command_line(arg)
```

## <a id="err"></a>Errors

<a id="err-1"></a>**1. ~/Desktop/autoodocs/markdown.lua:1233**
*↳ [@run 10.](#run-10)*

Header file not found

```lua
        if options.header then
```

<a id="err-1-1"></a>**1.1 ~/Desktop/autoodocs/markdown.lua:1260**
*↳ [@err 1.](#err-1)*

Stylesheet file not found for inline inclusion

```lua
            if options.inline_style then
                local style = ""
                local f = io.open(options.stylesheet)
                if f then
                    style = f:read("*a") f:close()
                else
                    error("Could not include style sheet " .. options.stylesheet .. ": File not found")
                end
                header = header:gsub('<link rel="stylesheet" type="text/css" href="STYLESHEET" />',
                    "<style type=\"text/css\"><!--\n" .. style .. "\n--></style>")
            else
                header = header:gsub("STYLESHEET", options.stylesheet)
            end
```

<a id="err-2"></a>**2. ~/Desktop/autoodocs/markdown.lua:1351**
*↳ [@run 10.](#run-10)*

Footer file not found

```lua
        if options.footer then
            local f = io.open(options.footer) or error("Could not open file: " .. options.footer)
            footer = f:read("*a")
            f:close()
```

<a id="err-3"></a>**3. ~/Desktop/autoodocs/markdown.lua:1424**
*↳ [@run 10.](#run-10)*

Test file not found

```lua
        local f = io.open(n)
        if f then
            f:close() dofile(n)
        else
            error("Cannot find markdown-tests.lua")
        end
        run_stdin = false
```

<a id="err-4"></a>**4. ~/Desktop/autoodocs/markdown.lua:1434**
*↳ [@run 10.](#run-10)*

Input or output file cannot be opened

```lua
    op:arg(function(path)
            local file = io.open(path) or error("Could not open file: " .. path)
            local s = file:read("*a")
            file:close()
            s = run(s, options)
            file = io.open(outpath(path, options), "w") or error("Could not open output file: " .. outpath(path, options))
            file:write(s)
            file:close()
            run_stdin = false
        end
    )
```

