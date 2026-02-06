-- @def:3 Localize functions for performance
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
local gsub   = string.gsub
local match  = string.match

-- @def:2 Import utils for trim
local utils = require("lib.utils")
local trim = utils.trim

-- @def:1 Module table
local M = {}

-- @def:2 Map tag prefixes to anchor slugs and section titles
M.TAG_SEC   = {CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}
M.TAG_ORDER = {"CHK", "DEF", "RUN", "ERR"}

-- @run Generate a slug from a file path for anchors
local function slugify(path)
    local s = gsub(path, "^.*/", "")  -- basename
    s = gsub(s, "%.", "-")
    s = gsub(s, "[^%w%-]", "")
    return s:lower()
end

-- @run Render a single entry
local function render_entry(w, r)
    -- Entry heading with anchor
    if r.parent then
        w(fmt('<a id="%s"></a>**%s %s**\n', r.anchor, r.idx, r.loc))
        w(fmt("*↳ [@%s %s](#%s)*\n\n", M.TAG_SEC[r.parent.tag], r.parent.idx, r.parent.anchor))
    else
        w(fmt('<a id="%s"></a>**%s** `%s`\n\n', r.anchor, r.idx, r.loc))
    end

    -- Text content with optional admonition
    if r.adm then
        local first_text = true
        for tline in gmatch(r.text, "[^\031]+") do
            local tr = trim(tline)
            if tr ~= "" then
                if first_text then
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
            local tr = trim(tline)
            if tr ~= "" then
                if first_text then
                    w(tr .. "\n\n")
                    first_text = false
                else
                    w(fmt("> %s\n\n", tr))
                end
            end
        end
    end

    -- Code subject block
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

-- @run Render records organized by file with TOC
function M.render_markdown(by_file, file_order)
    local out = {}
    local function w(s) out[#out + 1] = s end

    -- Table of Contents
    w("## Contents\n\n")
    for _, file in ipairs(file_order) do
        local slug = slugify(file)
        local basename = match(file, "([^/]+)$") or file
        w(fmt("- [%s](#%s)\n", basename, slug))
    end
    w("\n---\n\n")

    -- Render each file section
    for _, file in ipairs(file_order) do
        local entries = by_file[file]
        local slug = slugify(file)
        local basename = match(file, "([^/]+)$") or file

        w(fmt('## <a id="%s"></a>%s\n\n', slug, basename))
        w(fmt("`%s`\n\n", file))

        -- Group entries by tag type within this file
        local by_tag = {CHK={}, DEF={}, RUN={}, ERR={}}
        for _, r in ipairs(entries) do
            by_tag[r.tag][#by_tag[r.tag] + 1] = r
        end

        -- Render each tag section
        for _, tag in ipairs(M.TAG_ORDER) do
            local tag_entries = by_tag[tag]
            if #tag_entries > 0 then
                w(fmt("### %s\n\n", M.TAG_TITLE[tag]))
                for _, r in ipairs(tag_entries) do
                    render_entry(w, r)
                end
            end
        end

        w("---\n\n")
    end

    return concat(out)
end

-- @run Group records by file and assign indices
function M.group_records(records)
    local TAG_SEC = M.TAG_SEC
    local by_file = {}
    local file_order = {}
    local file_seen = {}

    -- Group by file, preserving order
    for _, r in ipairs(records) do
        if not file_seen[r.file] then
            file_seen[r.file] = true
            file_order[#file_order + 1] = r.file
            by_file[r.file] = {}
        end
        by_file[r.file][#by_file[r.file] + 1] = r
    end

    -- Assign indices per file per tag
    for _, file in ipairs(file_order) do
        local entries = by_file[file]
        local mi = {CHK=0, DEF=0, RUN=0, ERR=0}
        local scope = {}

        for _, r in ipairs(entries) do
            -- Handle parent relationships via indentation
            if r.indent > 0 then
                for d = r.indent - 1, 0, -1 do
                    if scope[d] then r.parent = scope[d]; break end
                end
            end
            scope[r.indent] = r

            local t = r.tag
            local file_slug = slugify(file)

            if r.parent and r.parent.tag == t then
                r.parent._cc = (r.parent._cc or 0) + 1
                local cc = r.parent._cc
                if r.parent.depth == 0 then
                    r.idx = fmt("%s%d", r.parent.idx, cc)
                else
                    r.idx = fmt("%s.%d", r.parent.idx, cc)
                end
                r.anchor = fmt("%s-%s-%d", file_slug, r.parent.anchor, cc)
                r.depth = r.parent.depth + 1
            else
                mi[t] = mi[t] + 1
                r.idx = fmt("%d.", mi[t])
                r.anchor = fmt("%s-%s-%d", file_slug, TAG_SEC[t], mi[t])
                r.depth = 0
            end
        end
    end

    return by_file, file_order
end

return M
