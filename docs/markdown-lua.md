# markdown.lua

`~/Desktop/autoodocs/markdown.lua`

Markdown to HTML converter with GitHub-style callouts and TOC generation

Mostly stolen from https://github.com/speedata/luamarkdown with minor modifications for our parsers.

## <a id="chk"></a>Checks

### <a id="chk-1"></a>Lua 5.1/5.2 compatibility

`~/Desktop/autoodocs/markdown.lua:121`


### <a id="chk-2"></a>Returns true if line is a ruler of repeated characters

`~/Desktop/autoodocs/markdown.lua:390`

The line must contain at least three char characters and contain only spaces and

> char characters.

```lua
local function is_ruler_of(line, char)
    if not line:match("^[ %" .. char .. "]*$") then return false end
    if not line:match("%" .. char .. ".*%" .. char .. ".*%" .. char) then return false end
    return true
end
```

### <a id="chk-3"></a>Classify block-level formatting in a line

`~/Desktop/autoodocs/markdown.lua:399`


## <a id="def"></a>Defines

### <a id="def-1"></a>Forward declarations for mutually recursive functions

`~/Desktop/autoodocs/markdown.lua:124`

```lua
local span_transform, encode_backslash_escapes, block_transform, blocks_to_html
```

### <a id="def-2"></a>Map values in table through function f

`~/Desktop/autoodocs/markdown.lua:131`

```lua
local function map(t, f)
    local out = {}
    for k,v in pairs(t) do out[k] = f(v,k) end
    return out
end
```

### <a id="def-3"></a>Identity function, useful as a placeholder

`~/Desktop/autoodocs/markdown.lua:138`

```lua
local function identity(text) return text end
```

### <a id="def-4"></a>Functional style ternary (no short circuit)

`~/Desktop/autoodocs/markdown.lua:141`

```lua
local function iff(t, a, b) if t then return a else return b end end
```

### <a id="def-5"></a>Hash data into unique alphanumeric strings

`~/Desktop/autoodocs/markdown.lua:255`

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

### <a id="def-6"></a>Protect document parts from modification

`~/Desktop/autoodocs/markdown.lua:307`

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

### <a id="def-7"></a>Characters with special markdown meaning needing escape

`~/Desktop/autoodocs/markdown.lua:830`

```lua
escape_chars = "'\\`*_{}[]()>#+-.!'"
escape_table = {}
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Split text into array of lines by separator

`~/Desktop/autoodocs/markdown.lua:144`

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

### <a id="run-2"></a>Block-level text transforms working with arrays of lines

`~/Desktop/autoodocs/markdown.lua:388`


### <a id="run-3"></a>Convert normal + ruler lines to header entries

`~/Desktop/autoodocs/markdown.lua:464`


### <a id="run-4"></a>Convert list blocks to protected HTML

`~/Desktop/autoodocs/markdown.lua:482`


### <a id="run-5"></a>Convert blockquote markers with GitHub callout support

`~/Desktop/autoodocs/markdown.lua:605`


### <a id="run-6"></a>Convert fenced code blocks with language hints

`~/Desktop/autoodocs/markdown.lua:667`


### <a id="run-7"></a>Span-level text transforms for inline formatting

`~/Desktop/autoodocs/markdown.lua:828`


### <a id="run-8"></a>Normalize line endings, tabs, and whitespace

`~/Desktop/autoodocs/markdown.lua:1124`


### <a id="run-9"></a>Main markdown processing pipeline

`~/Desktop/autoodocs/markdown.lua:1169`

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

### <a id="run-10"></a>CLI handler with HTML wrapping and TOC generation

`~/Desktop/autoodocs/markdown.lua:1272`


## <a id="err"></a>Errors

<a id="err-1"></a>**1. ~/Desktop/autoodocs/markdown.lua:1279**
*↳ [@run 10.](#run-10)*

Header file not found


<a id="err-1-1"></a>**1.1 ~/Desktop/autoodocs/markdown.lua:1307**
*↳ [@err 1.](#err-1)*

Stylesheet file not found for inline inclusion


<a id="err-2"></a>**2. ~/Desktop/autoodocs/markdown.lua:1394**
*↳ [@run 10.](#run-10)*

Footer file not found


<a id="err-3"></a>**3. ~/Desktop/autoodocs/markdown.lua:1457**
*↳ [@run 10.](#run-10)*

Test file not found


<a id="err-4"></a>**4. ~/Desktop/autoodocs/markdown.lua:1467**
*↳ [@run 10.](#run-10)*

Input or output file cannot be opened


