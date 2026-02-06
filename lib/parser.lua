-- @gen Comment parser that extracts documentation tags from source files
-- @def:7 Localize functions for hot loop perf
local find   = string.find
local sub    = string.sub
local byte   = string.byte
local match  = string.match
local gmatch = string.gmatch
local gsub   = string.gsub
local open   = io.open

-- @def:5 Localize utils for hoot loop perf
local utils = require("lib.utils")
local trim = utils.trim
local trim_lead = utils.trim_lead
local trim_trail = utils.trim_trail
local get_lang = utils.get_lang

-- @def:1 Localize map
local M = {}

-- @def:1 Hoisted `TAGS` table avoids per-call allocation in `strip_tags`
local TAGS = {"@gen", "@def", "@chk", "@run", "@err"}

-- @def:1 Map `!x` suffixes to admonition types
M.ADMONITIONS = {n="NOTE", t="TIP", i="IMPORTANT", w="WARNING", c="CAUTION"}

-- @chk:6 Test whether a line contains any documentation tag
-- early `@` check short-circuits lines with no tags
function M.has_tag(line)
    if not find(line, "@", 1, true) then return nil end
    return find(line, "@gen", 1, true) or find(line, "@def", 1, true) or
           find(line, "@chk", 1, true) or find(line, "@run", 1, true) or
           find(line, "@err", 1, true)
end

-- @chk:8 Classify a tagged line into `GEN`, `DEF`, `CHK`, `RUN`, or `ERR`
function M.get_tag(line)
    if     find(line, "@gen", 1, true) then return "GEN"
    elseif find(line, "@def", 1, true) then return "DEF"
    elseif find(line, "@chk", 1, true) then return "CHK"
    elseif find(line, "@run", 1, true) then return "RUN"
    elseif find(line, "@err", 1, true) then return "ERR"
    end
end

-- @chk:6 Extract the subject line count from `@tag:N` syntax
-- using pattern capture after the colon
function M.get_subject_count(text)
    local n = match(text, "@gen:(%d+)") or match(text, "@def:(%d+)") or
              match(text, "@chk:(%d+)") or match(text, "@run:(%d+)") or
              match(text, "@err:(%d+)")
    return tonumber(n) or 0
end

-- @run:9 Strip `@tag:N` and trailing digits from text
-- rejoining prefix with remaining content
local function strip_tag_num(text, tag)
    local pos = find(text, tag .. ":", 1, true)
    if not pos then return text end
    local prefix = sub(text, 1, pos - 1)
    local rest = sub(text, pos + #tag + 1)
    rest = gsub(rest, "^%d+!?%a?", "")
    rest = gsub(rest, "^ ", "", 1)
    return prefix .. rest
end

-- @chk:4 Extract `!x` admonition suffix from tag syntax
function M.get_admonition(text)
    local code = match(text, "@%a+:?%d*!(%a)")
    if code then return M.ADMONITIONS[code] end
end

-- @run:22 Remove `@tag`, `@tag:N`, or `@tag!x` syntax from comment text
-- delegates to `strip_tag_num` for `:N` and `:N!x` variants
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

-- @chk:21 Detect comment style via byte-level prefix check
-- skips leading whitespace without allocating a trimmed copy
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

-- @run Strip comment delimiters and extract inner text
-- for all styles including block continuations
function M.strip_comment(line, style)
    -- @chk shell type comments
    if style == "hash" then
        local sc = match(line, "#(.*)") or ""
        return trim_lead(sc)

    -- @chk double-slash comments
    elseif style == "dslash" then
        local sc = match(line, "//(.*)") or ""
        return trim_lead(sc)

    -- @chk double-dash comments
    elseif style == "ddash" then
        local sc = match(line, "%-%-(.*)") or ""
        return trim_lead(sc)

    -- @chk C-style block opening
    elseif style == "cblock" then
        local sc = match(line, "/%*(.*)") or ""
        sc = trim_trail(sc)
        if sub(sc, -2) == "*/" then sc = sub(sc, 1, -3) end
        return trim(sc)

    -- @chk HTML comment opening
    elseif style == "html" then
        local sc = match(line, "<!%-%-(.*)") or ""
        sc = trim_trail(sc)
        if sub(sc, -3) == "-->" then sc = sub(sc, 1, -4) end
        return trim(sc)

    -- @chk block comment continuation lines
    elseif style == "cblock_cont" then
        local sc = trim_trail(line)
        if sub(sc, -2) == "*/" then sc = sub(sc, 1, -3) end
        sc = trim_lead(sc)
        if sub(sc, 1, 1) == "*" then
            sc = sub(sc, 2)
            sc = trim_lead(sc)
        end
        return trim_trail(sc)

    -- @chk html closing
    elseif style == "html_cont" then
        local sc = trim_trail(line)
        if sub(sc, -3) == "-->" then sc = sub(sc, 1, -4) end
        return trim(sc)

    -- @chk triple-quote docstring styles
    elseif style == "dquote" then
        local sc = match(line, '"""(.*)') or ""
        sc = trim_trail(sc)
        if sub(sc, -3) == '"""' then sc = sub(sc, 1, -4) end
        return trim(sc)

    -- @chk single-quote docstring style
    elseif style == "squote" then
        local sc = match(line, "'''(.*)") or ""
        sc = trim_trail(sc)
        if sub(sc, -3) == "'''" then sc = sub(sc, 1, -4) end
        return trim(sc)

    -- @chk docstring continuation lines
    -- no opening delimiter to strip; checks both `"""` and `'''` closers
    elseif style == "docstring_cont" then
        local sc = trim_trail(line)
        if sub(sc, -3) == '"""' then
            sc = sub(sc, 1, -4)
        elseif sub(sc, -3) == "'''" then
            sc = sub(sc, 1, -4)
        end
        return trim(sc)
    end
    return line
end

-- @run Walk one file as a line-by-line state machine
-- extracting tagged comments into `records` table
function M.process_file(filepath, records, HOME, US)
    -- @def:4!n Bulk-read file first so `get_lang` reuses the buffer
    -- avoids a second `open`+`read` just for shebang detection
    local f = open(filepath, "r")
    if not f then return 0 end
    local content = f:read("*a")
    f:close()

    -- @def:15 Initialize per-file state machine variables
    -- `get_lang` receives first line to avoid reopening the file
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

    -- @run:37!n Emit a documentation record or defer for subject capture
    -- `lang` is passed through as-is, empty string means no fence label
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

    -- @run:9 Flush deferred record with captured `subj` lines
    local function flush_pending()
        if pending then
            pending.subj = subj
            records[#records + 1] = pending
            pending = nil
            subj    = ""
            capture = 0
        end
    end

    local pos = 1
    local clen = #content

    while pos <= clen do
        local nl = find(content, "\n", pos, true) or clen + 1
        local line = sub(content, pos, nl - 1)
        pos = nl + 1
        ln = ln + 1

        -- @run:10 Subject line capture mode
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

        -- @run:11 Accumulate C-style block comment with tag
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

        -- @run:11 Accumulate HTML comment with tag
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

        -- @chk Scan untagged block comment for tags
        if state == "cblock_scan" then
            if find(line, "*/", 1, true) then
                state = ""
            else
                if M.has_tag(line) then
                    tag   = M.get_tag(line)
                    start = tostring(ln)
                    local ti = 1; while byte(line,ti) == 32 or byte(line,ti) == 9 do ti = ti+1 end; tag_indent = ti-1
                    local sc = M.strip_comment(line, "cblock_cont")
                    nsubj = M.get_subject_count(sc)
                    adm   = M.get_admonition(sc)
                    text  = M.strip_tags(sc)
                    state = "cblock"
                end
            end
            goto continue
        end

        -- @chk Scan untagged HTML comment for tags
        if state == "html_scan" then
            if find(line, "-->", 1, true) then
                state = ""
            else
                if M.has_tag(line) then
                    tag   = M.get_tag(line)
                    start = tostring(ln)
                    local ti = 1; while byte(line,ti) == 32 or byte(line,ti) == 9 do ti = ti+1 end; tag_indent = ti-1
                    local sc = M.strip_comment(line, "html_cont")
                    nsubj = M.get_subject_count(sc)
                    adm   = M.get_admonition(sc)
                    text  = M.strip_tags(sc)
                    state = "html"
                end
            end
            goto continue
        end

        -- @run:12 Accumulate docstring with tag
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

        -- @chk Scan untagged docstring for tags
        if state == "dquote_scan" or state == "squote_scan" then
            local close, promote
            if state == "dquote_scan" then
                close = '"""'; promote = "dquote"
            else
                close = "'''"; promote = "squote"
            end
            if find(line, close, 1, true) then
                state = ""
            else
                if M.has_tag(line) then
                    tag   = M.get_tag(line)
                    start = tostring(ln)
                    local ti = 1; while byte(line,ti) == 32 or byte(line,ti) == 9 do ti = ti+1 end; tag_indent = ti-1
                    local sc = M.strip_comment(line, "docstring_cont")
                    nsubj = M.get_subject_count(sc)
                    adm   = M.get_admonition(sc)
                    text  = M.strip_tags(sc)
                    state = promote
                end
            end
            goto continue
        end

        -- @chk:1 Detect comment style of current line
        local style = M.detect_style(line)

        -- @run:13 Continue or close existing single-line comment block
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

        -- @run:22 Dispatch new tagged comment by style
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

        -- @chk Untagged block comment start - scan for tags
        elseif style == "cblock" then
            if not find(line, "*/", 1, true) then state = "cblock_scan" end
        -- @chk Untagged HTML comment start
        elseif style == "html" then
            if not find(line, "-->", 1, true) then state = "html_scan" end
        -- @chk Untagged double-quote docstring start
        elseif style == "dquote" then
            local rest = match(line, '"""(.*)')
            if not (rest and find(rest, '"""', 1, true)) then state = "dquote_scan" end
        -- @chk Untagged single-quote docstring start
        elseif style == "squote" then
            local rest = match(line, "'''(.*)")
            if not (rest and find(rest, "'''", 1, true)) then state = "squote_scan" end
        end

        -- @run:7 Begin subject capture if waiting and hit a code line
        if cap_want > 0 and style == "none" then
            capture  = cap_want
            cap_want = 0
            subj     = line
            capture  = capture - 1
            if capture == 0 then flush_pending() end
        end

        ::continue::
    end

    emit()
    if cap_want > 0 then cap_want = 0 end
    flush_pending()
    return ln
end

return M
