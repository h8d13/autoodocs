-- @gen Markdown renderer that generates documentation pages with cross-references
-- @def:6 Localize functions for performance
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
local gsub   = string.gsub
local match  = string.match
local sub    = string.sub

-- @def:2 Import utils for trim
local utils = require("lib.utils")
local trim = utils.trim

-- @def:1 Module table
local M = {}

-- @def:3 Map tag prefixes to anchor slugs and section titles
M.TAG_SEC   = {GEN="gen", CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {GEN="General", CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}
M.TAG_ORDER = {"GEN", "CHK", "DEF", "RUN", "ERR"}

-- @run Generate a slug from a file path for anchors/filenames
local function slugify(path)
    local s = gsub(path, "^.*/", "")  -- basename
    s = gsub(s, "%.", "-")
    s = gsub(s, "[^%w%-]", "")
    return s:lower()
end

-- @def:1 Line-to-anchor mapping built during grouping
M.line_map = {}

-- @run:16 Convert @src:filepath:line to clickable markdown links
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
        local display = line ~= "" and (path .. ":" .. line) or path
        local href = anchor ~= "" and fmt("%s.html#%s", slug, anchor) or (slug .. ".html")
        return fmt("[%s](%s)", display, href)
    end)
end

-- @run Render a single entry
local function render_entry(w, r)
    if r.parent then
        -- Child entry: bold text
        w(fmt('<a id="%s"></a>**%s %s**\n', r.anchor, r.idx, r.loc))
        w(fmt("*↳ [@%s %s](#%s)*\n\n", M.TAG_SEC[r.parent.tag], r.parent.idx, r.parent.anchor))
    else
        -- Top-level entry: h3 header (appears in TOC)
        local title = r.text:match("^([^\031]+)") or ""
        title = trim(title)
        if #title > 90 then title = title:sub(1, 87) .. "..." end
        w(fmt('### <a id="%s"></a>%s\n\n', r.anchor, title))
        w(fmt('`%s`\n\n', r.loc))
    end

    -- For top-level entries, skip first line (used as h3 title)
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

    if r.subj and r.subj ~= "" then
        if r.lang and r.lang ~= "" then
            w(fmt("```%s\n", r.lang))
        else
            w("```\n")
        end
        for sline in gmatch(r.subj .. "\031", "(.-)\031") do
            w(sline .. "\n")
        end
        w("```\n")
    end
    w("\n")
end

-- @run Render index page
function M.render_index(file_order)
    local out = {}
    local function w(s) out[#out + 1] = s end

    w("# Documentation\n\n")
    w("Select a file from the sidebar to view its documentation.\n\n")

    -- Hidden nav data for TOC extraction
    -- Find common path prefix across all files
    local prefix = match(file_order[1] or "", "^(.*/)") or ""
    for _, file in ipairs(file_order) do
        while #prefix > 0 and sub(file, 1, #prefix) ~= prefix do
            prefix = match(sub(prefix, 1, -2), "^(.*/)") or ""
        end
    end

    w("<!-- NAV\n")
    for _, file in ipairs(file_order) do
        local slug = slugify(file)
        local display = sub(file, #prefix + 1)
        w(fmt("[%s](%s.html)\n", display, slug))
    end
    w("-->\n")

    return concat(out)
end

-- @run Render a single file's documentation page
function M.render_file_page(file, entries)
    local out = {}
    local function w(s) out[#out + 1] = s end

    local basename = match(file, "([^/]+)$") or file
    w(fmt("# %s\n\n", basename))
    w(fmt("`%s`\n\n", file))

    -- Group entries by tag type
    local by_tag = {GEN={}, CHK={}, DEF={}, RUN={}, ERR={}}
    for _, r in ipairs(entries) do
        by_tag[r.tag][#by_tag[r.tag] + 1] = r
    end

    -- Render each tag section
    for _, tag in ipairs(M.TAG_ORDER) do
        local tag_entries = by_tag[tag]
        if #tag_entries > 0 then
            w(fmt('## <a id="%s"></a>%s\n\n', M.TAG_SEC[tag], M.TAG_TITLE[tag]))
            for _, r in ipairs(tag_entries) do
                render_entry(w, r)
            end
        end
    end

    return concat(out)
end

-- @run Group records by file and assign indices
function M.group_records(records)
    local TAG_SEC = M.TAG_SEC
    local by_file = {}
    local file_order = {}
    local file_seen = {}
    M.line_map = {}

    for _, r in ipairs(records) do
        if not file_seen[r.file] then
            file_seen[r.file] = true
            file_order[#file_order + 1] = r.file
            by_file[r.file] = {}
        end
        by_file[r.file][#by_file[r.file] + 1] = r
    end

    for _, file in ipairs(file_order) do
        local entries = by_file[file]
        local mi = {GEN=0, CHK=0, DEF=0, RUN=0, ERR=0}
        local scope = {}
        local slug = slugify(file)
        M.line_map[slug] = {}

        for _, r in ipairs(entries) do
            if r.indent > 0 then
                for d = r.indent - 1, 0, -1 do
                    if scope[d] then r.parent = scope[d]; break end
                end
            end
            scope[r.indent] = r

            local t = r.tag
            if r.parent and r.parent.tag == t then
                r.parent._cc = (r.parent._cc or 0) + 1
                local cc = r.parent._cc
                if r.parent.depth == 0 then
                    r.idx = fmt("%s%d", r.parent.idx, cc)
                else
                    r.idx = fmt("%s.%d", r.parent.idx, cc)
                end
                r.anchor = fmt("%s-%d", r.parent.anchor, cc)
                r.depth = r.parent.depth + 1
            else
                mi[t] = mi[t] + 1
                r.idx = fmt("%d.", mi[t])
                r.anchor = fmt("%s-%d", TAG_SEC[t], mi[t])
                r.depth = 0
            end

            -- Build line-to-anchor mapping
            local ln = tonumber(match(r.loc, ":(%d+)$"))
            if ln then
                M.line_map[slug][#M.line_map[slug] + 1] = {line = ln, anchor = r.anchor}
            end
        end
    end

    return by_file, file_order
end

-- @run Get slug for a file path
M.slugify = slugify

return M
