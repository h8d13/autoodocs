# markdown.lua

`~/Desktop/autoodocs/markdown.lua`

## <a id="chk"></a>Checks

### <a id="chk-1"></a>Returns true if line is a ruler of repeated characters

`~/Desktop/autoodocs/markdown.lua:393`

The line must contain at least three char characters and contain only spaces and

> char characters.

```lua
local function is_ruler_of(line, char)
    if not line:match("^[ %" .. char .. "]*$") then return false end
    if not line:match("%" .. char .. ".*%" .. char .. ".*%" .. char) then return false end
    return true
end

```

### <a id="chk-2"></a>Classify block-level formatting in a line

`~/Desktop/autoodocs/markdown.lua:402`


## <a id="def"></a>Defines

### <a id="def-1"></a>Lua 5.1/5.2 compatibility

`~/Desktop/autoodocs/markdown.lua:124`

```lua
local unpack = unpack or table.unpack
```

### <a id="def-2"></a>Forward declarations for mutually recursive functions

`~/Desktop/autoodocs/markdown.lua:127`

```lua
local span_transform, encode_backslash_escapes, block_transform, blocks_to_html, blocks_to_html
```

### <a id="def-3"></a>Map values in table through function f

`~/Desktop/autoodocs/markdown.lua:134`

```lua
local function map(t, f)
    local out = {}
    for k,v in pairs(t) do out[k] = f(v,k) end
    return out
end
```

### <a id="def-4"></a>Identity function, useful as a placeholder

`~/Desktop/autoodocs/markdown.lua:141`

```lua
local function identity(text) return text end
```

### <a id="def-5"></a>Functional style ternary (no short circuit)

`~/Desktop/autoodocs/markdown.lua:144`

```lua
local function iff(t, a, b) if t then return a else return b end end
```

### <a id="def-6"></a>Hash data into unique alphanumeric strings

`~/Desktop/autoodocs/markdown.lua:258`

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

### <a id="def-7"></a>Protect document parts from modification

`~/Desktop/autoodocs/markdown.lua:310`

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

### <a id="def-8"></a>Characters with special markdown meaning needing escape

`~/Desktop/autoodocs/markdown.lua:833`

```lua
escape_chars = "'\\`*_{}[]()>#+-.!'"
escape_table = {}
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Split text into array of lines by separator

`~/Desktop/autoodocs/markdown.lua:147`

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

`~/Desktop/autoodocs/markdown.lua:391`


### <a id="run-3"></a>Convert normal + ruler lines to header entries

`~/Desktop/autoodocs/markdown.lua:467`


### <a id="run-4"></a>Convert list blocks to protected HTML

`~/Desktop/autoodocs/markdown.lua:485`


### <a id="run-5"></a>Convert blockquote markers with GitHub callout support

`~/Desktop/autoodocs/markdown.lua:608`


### <a id="run-6"></a>Convert fenced code blocks with language hints

`~/Desktop/autoodocs/markdown.lua:670`


### <a id="run-7"></a>Span-level text transforms for inline formatting

`~/Desktop/autoodocs/markdown.lua:831`


### <a id="run-8"></a>Normalize line endings, tabs, and whitespace

`~/Desktop/autoodocs/markdown.lua:1121`


### <a id="run-9"></a>Main markdown processing pipeline

`~/Desktop/autoodocs/markdown.lua:1166`

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
```

### <a id="run-10"></a>CLI handler with HTML wrapping and TOC generation

`~/Desktop/autoodocs/markdown.lua:1269`


