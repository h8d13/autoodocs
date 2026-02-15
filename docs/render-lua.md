# render.lua

`~/Desktop/autoodocs/lib/render.lua`

Markdown renderer that generates documentation pages with cross-references

## <a id="chk"></a>Checks

<a id="chk-1"></a>**1. ~/Desktop/autoodocs/lib/render.lua:136**
*↳ [@run 4.](#run-4)*

Detect and include README.md content

```lua
    local readme_content = nil
    for _, name in ipairs({"README.md", "readme.md"}) do
        local f = io.open((scan_dir or ".") .. "/" .. name, "r")
        if f then
            readme_content = f:read("*a")
            -- Strip autodocs HTML comments
            readme_content = readme_content:gsub("<!%-%- @%w[^>]* %-%->%s*", "")
            f:close()
            break
        end
    end

    if readme_content then
        w(readme_content .. "\n\n")
    else
        w("Select a file from the sidebar to view its documentation.\n\n")
    end
```

## <a id="def"></a>Defines

### <a id="def-1"></a>1. Localize functions for performance

`~/Desktop/autoodocs/lib/render.lua:2`

```lua
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
local gsub   = string.gsub
local match  = string.match
local sub    = string.sub
```

### <a id="def-2"></a>2. Import utils for trim

`~/Desktop/autoodocs/lib/render.lua:10`

```lua
local utils = require("lib.utils")
local trim = utils.trim
```

### <a id="def-3"></a>3. Module table

`~/Desktop/autoodocs/lib/render.lua:14`

```lua
local M = {}
```

### <a id="def-4"></a>4. Map tag prefixes to anchor slugs and section titles

`~/Desktop/autoodocs/lib/render.lua:17`

```lua
M.TAG_SEC   = {GEN="gen", CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {GEN="General", CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}
M.TAG_ORDER = {"GEN", "CHK", "DEF", "RUN", "ERR"}
```

### <a id="def-5"></a>5. Line-to-anchor mapping built during grouping

`~/Desktop/autoodocs/lib/render.lua:30`

```lua
M.line_map = {}
```

<a id="def-6"></a>**6. ~/Desktop/autoodocs/lib/render.lua:214**
*↳ [@run 5.](#run-5)*

Group entries by tag type

```lua
    local by_tag = {GEN={}, CHK={}, DEF={}, RUN={}, ERR={}}
    for _, r in ipairs(entries) do
        by_tag[r.tag][#by_tag[r.tag] + 1] = r
    end
```

## <a id="run"></a>Runners

### <a id="run-1"></a>1. Generate a slug from a file path for anchors/filenames

`~/Desktop/autoodocs/lib/render.lua:22`


### <a id="run-2"></a>2. Convert @src:filepath:line to clickable markdown links

`~/Desktop/autoodocs/lib/render.lua:33`

```lua
local function link_sources(text)
    text = gsub(text, "@ref %[(.-)%]%((.-)%)", "*↗ [%1](%2)*")
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
        local display = line ~= "" and (path .. ":" .. line) or path
        local href = anchor ~= "" and fmt("%s.html#%s", slug, anchor) or (slug .. ".html")
        return fmt("*↳ [%s](%s)*", display, href)
    end)
end
```

### <a id="run-3"></a>3. Render a single entry

`~/Desktop/autoodocs/lib/render.lua:52`


<a id="run-3-1"></a>**3.1 ~/Desktop/autoodocs/lib/render.lua:54**
*↳ [@run 3.](#run-3)*

GEN entries render as plain text, no header

```lua
    if r.tag == "GEN" then
        for tline in gmatch(r.text, "[^\031]+") do
            local tr = link_sources(trim(tline))
            if tr ~= "" then w(tr .. "\n\n") end
        end
        return
    end
```

<a id="run-3-2"></a>**3.2 ~/Desktop/autoodocs/lib/render.lua:63**
*↳ [@run 3.](#run-3)*

Build entry header with anchor and index

> child entries show parent backlink, top-level entries use h3

```lua
    if r.parent then
        -- Child entry: bold text
        w(fmt('<a id="%s"></a>**%s %s**\n', r.anchor, r.idx, r.loc))
        w(fmt("*↳ [@%s %s](#%s)*\n\n", M.TAG_SEC[r.parent.tag], r.parent.idx, r.parent.anchor))
    else
        -- Top-level entry: h3 header (appears in TOC)
        local title = r.text:match("^([^\031]+)") or ""
        title = trim(title)
        if title == "" then title = r.text:match("\031([^\031]+)") or "" end
        title = trim(title)
        if #title > 90 then title = title:sub(1, 87) .. "..." end
        w(fmt('### <a id="%s"></a>%s %s\n\n', r.anchor, r.idx, title))
```

<a id="run-3-3"></a>**3.3 ~/Desktop/autoodocs/lib/render.lua:80**
*↳ [@run 3.](#run-3)*

Render text lines through link_sources with admonition support

```lua
    local skip_first = (not r.parent)

    if r.adm then
        local first_text = true
        for tline in gmatch(r.text, "[^\031]+") do
            local tr = link_sources(trim(tline))
            if tr ~= "" then
                if skip_first then
                    skip_first = false
                elseif first_text then
                    w(fmt("> [!%s]\n> %s\n\n", r.adm, tr))
                    first_text = false
                else
                    w(tr .. "\n\n")
                end
            end
        end
    else
        local first_text = true
        for tline in gmatch(r.text, "[^\031]+") do
            local tr = link_sources(trim(tline))
            if tr ~= "" then
                if skip_first then
                    skip_first = false
                elseif first_text then
                    w(tr .. "\n\n")
                    first_text = false
                else
                    w(fmt("> %s\n\n", tr))
                end
            end
        end
    end
```

### <a id="run-4"></a>4. Render index page

`~/Desktop/autoodocs/lib/render.lua:129`


<a id="run-4-1"></a>**4.1 ~/Desktop/autoodocs/lib/render.lua:155**
*↳ [@run 4.](#run-4)*

Find common path prefix and group files by directory

```lua
    local prefix = match(file_order[1] or "", "^(.*/)") or ""
    for _, file in ipairs(file_order) do
        while #prefix > 0 and sub(file, 1, #prefix) ~= prefix do
            prefix = match(sub(prefix, 1, -2), "^(.*/)") or ""
        end
    end

    -- Group files: root files first, then by subdirectory
    local root_files = {}
    local dir_files = {}
    for _, file in ipairs(file_order) do
        local rel = sub(file, #prefix + 1)
        local dir = match(rel, "^([^/]+)/")
        if dir then
            dir_files[dir] = dir_files[dir] or {}
            dir_files[dir][#dir_files[dir] + 1] = {file = file, rel = rel}
        else
            root_files[#root_files + 1] = {file = file, rel = rel}
        end
    end
```

<a id="run-4-2"></a>**4.2 ~/Desktop/autoodocs/lib/render.lua:177**
*↳ [@run 4.](#run-4)*

Write hidden NAV comment for TOC extraction

```lua
    w("<!-- NAV\n")
    -- Root files first
    for _, f in ipairs(root_files) do
        local slug = slugify(f.file)
        w(fmt("[%s](%s.html)\n", f.rel, slug))
    end
    -- Then grouped subdirectories
    for dir, files in pairs(dir_files) do
        w(fmt("[>%s]\n", dir))
        for _, f in ipairs(files) do
            local slug = slugify(f.file)
            local basename = match(f.rel, "/(.+)$") or f.rel
            w(fmt("[%s](%s.html)\n", basename, slug))
        end
        w("[<]\n")
    end
    w("-->\n")
```

<a id="run-4-3"></a>**4.3 ~/Desktop/autoodocs/lib/render.lua:196**
*↳ [@run 4.](#run-4)*

Embed repo URL as HTML comment for sidebar link

> *↗ [autoodocs](https://github.com/h8d13/autoodocs)*

```lua
    if repo_url then
        w(fmt("<!-- REPO:%s -->\n", repo_url))
    end
```

### <a id="run-5"></a>5. Render a single file's documentation page

`~/Desktop/autoodocs/lib/render.lua:205`


<a id="run-5-1"></a>**5.1 ~/Desktop/autoodocs/lib/render.lua:220**
*↳ [@run 5.](#run-5)*

Render each tag section, GEN has no header

```lua
    for _, tag in ipairs(M.TAG_ORDER) do
        local tag_entries = by_tag[tag]
        if #tag_entries > 0 then
            if tag ~= "GEN" then
                w(fmt('## <a id="%s"></a>%s\n\n', M.TAG_SEC[tag], M.TAG_TITLE[tag]))
            end
            for _, r in ipairs(tag_entries) do
                render_entry(w, r)
            end
        end
    end
```

### <a id="run-6"></a>6. Group records by file and assign indices

`~/Desktop/autoodocs/lib/render.lua:236`


### <a id="run-7"></a>7. Get slug for a file path

`~/Desktop/autoodocs/lib/render.lua:297`


