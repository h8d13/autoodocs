# render.lua

`~/Desktop/autoodocs/lib/render.lua`

## <a id="def"></a>Defines

### <a id="def-1"></a>Localize functions for performance

`~/Desktop/autoodocs/lib/render.lua:1`

```lua
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
local gsub   = string.gsub
local match  = string.match
local sub    = string.sub
```

### <a id="def-2"></a>Import utils for trim

`~/Desktop/autoodocs/lib/render.lua:9`

```lua
local utils = require("lib.utils")
local trim = utils.trim
```

### <a id="def-3"></a>Module table

`~/Desktop/autoodocs/lib/render.lua:13`

```lua
local M = {}
```

### <a id="def-4"></a>Map tag prefixes to anchor slugs and section titles

`~/Desktop/autoodocs/lib/render.lua:16`

```lua
M.TAG_SEC   = {CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}
M.TAG_ORDER = {"CHK", "DEF", "RUN", "ERR"}
```

### <a id="def-5"></a>Line-to-anchor mapping built during grouping

`~/Desktop/autoodocs/lib/render.lua:29`

```lua
M.line_map = {}
```

## <a id="run"></a>Runners

### <a id="run-1"></a>Generate a slug from a file path for anchors/filenames

`~/Desktop/autoodocs/lib/render.lua:21`


### <a id="run-2"></a>Convert @src:filepath:line to clickable markdown links

`~/Desktop/autoodocs/lib/render.lua:32`

```lua
local function link_sources(text)
    return gsub(text, "@src:([^%s:]+):?(%d*)", function(path, line)
        local slug = slugify(path)
        local anchor = ""
        if line ~= "" and M.line_map[slug] then
            local ln = tonumber(line)
            for _, entry in ipairs(M.line_map[slug]) do
                if entry.line <= ln then anchor = entry.anchor
                else break end
            end
        end
```

### <a id="run-3"></a>Render a single entry

`~/Desktop/autoodocs/lib/render.lua:50`


### <a id="run-4"></a>Render index page

`~/Desktop/autoodocs/lib/render.lua:114`


### <a id="run-5"></a>Render a single file's documentation page

`~/Desktop/autoodocs/lib/render.lua:142`


### <a id="run-6"></a>Group records by file and assign indices

`~/Desktop/autoodocs/lib/render.lua:171`


### <a id="run-7"></a>Get slug for a file path

`~/Desktop/autoodocs/lib/render.lua:232`


