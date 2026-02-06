-- @def:3 Localize functions for performance
local fmt    = string.format
local gmatch = string.gmatch
local concat = table.concat
-- @def:2 Import utils for trim
local utils = require("lib.utils")
local trim = utils.trim
-- @def:1 Define map
local M = {}

-- @def:2 Map tag prefixes to anchor slugs and section titles
M.TAG_SEC   = {CHK="chk", DEF="def", RUN="run", ERR="err"}
M.TAG_TITLE = {CHK="Checks", DEF="Defines", RUN="Runners", ERR="Errors"}

-- @run:68 Render `records` into sectioned markdown
-- parentless entries become headings; children use bold anchors
function M.render_markdown(grouped)
    local out = {}
    local function w(s) out[#out + 1] = s end

    local function render_section(entries, prefix)
        if #entries == 0 then return end
        w(fmt("## %s (@%s)\n\n", M.TAG_TITLE[prefix], M.TAG_SEC[prefix]))

        for _, r in ipairs(entries) do
            if r.parent then
                w(fmt('<a id="%s"></a>**%s %s**\n', r.anchor, r.idx, r.loc))
                w(fmt("*↳ [@%s %s](#%s)*\n\n", M.TAG_SEC[r.parent.tag], r.parent.idx, r.parent.anchor))
            else
                w(fmt('### <a id="%s"></a>%s %s\n', r.anchor, r.idx, r.loc))
            end

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
    end

    render_section(grouped.CHK, "CHK")
    render_section(grouped.DEF, "DEF")
    render_section(grouped.RUN, "RUN")
    render_section(grouped.ERR, "ERR")

    return concat(out)
end

-- @run:35 Resolve parents, assign per-tag indices, group (single pass)
function M.group_records(records)
    local TAG_SEC = M.TAG_SEC
    local mi = {CHK=0, DEF=0, RUN=0, ERR=0}
    local grouped = {CHK={}, DEF={}, RUN={}, ERR={}}
    local scope = {}
    local scope_file = ""
    for _, r in ipairs(records) do
        if r.file ~= scope_file then
            scope_file = r.file
            scope = {}
        end
        if r.indent > 0 then
            for d = r.indent - 1, 0, -1 do
                if scope[d] then r.parent = scope[d]; break end
            end
        end
        scope[r.indent] = r
        local t = r.tag
        local g = grouped[t]
        g[#g + 1] = r
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
    end
    return grouped
end

return M
