# render.lua

`~/Desktop/autoodocs/lib/render.lua`

## Contents

- [Defines](#def)
- [Runners](#run)

## <a id="def"></a>Defines

<a id="def-1"></a>**1.** `~/Desktop/autoodocs/lib/render.lua:1`

Localize functions for performance

```lua
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
```

<a id="def-2"></a>**2.** `~/Desktop/autoodocs/lib/render.lua:8`

Import utils for trim

```lua
local utils = require("lib.utils")
local trim = utils.trim
```

<a id="def-3"></a>**3.** `~/Desktop/autoodocs/lib/render.lua:12`

Module table

```lua
local M = {}
```

<a id="def-4"></a>**4.** `~/Desktop/autoodocs/lib/render.lua:15`

Map tag prefixes to anchor slugs and section titles

```lua
M.TAG_SEC   = {CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}
```

## <a id="run"></a>Runners

<a id="run-1"></a>**1.** `~/Desktop/autoodocs/lib/render.lua:20`

Generate a slug from a file path for anchors/filenames


<a id="run-2"></a>**2.** `~/Desktop/autoodocs/lib/render.lua:28`

Render a single entry


<a id="run-3"></a>**3.** `~/Desktop/autoodocs/lib/render.lua:79`

Render index page with TOC


<a id="run-4"></a>**4.** `~/Desktop/autoodocs/lib/render.lua:93`

Render a single file's documentation page


<a id="run-5"></a>**5.** `~/Desktop/autoodocs/lib/render.lua:131`

Group records by file and assign indices


<a id="run-6"></a>**6.** `~/Desktop/autoodocs/lib/render.lua:183`

Get slug for a file path


