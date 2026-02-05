#!/usr/bin/env luajit
-- Simple HTTP server for serving markdown files

local socket = require("socket")
local md = dofile("markdown.lua")

local PORT = arg[1] or 8080

-- Read a file
local function read_file(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

-- Get content type
local function content_type(path)
    if path:match("%.css$") then return "text/css" end
    if path:match("%.js$") then return "application/javascript" end
    if path:match("%.html$") then return "text/html" end
    if path:match("%.md$") then return "text/html" end
    return "text/plain"
end

-- Render markdown to full HTML
local function render_markdown(content)
    local css = read_file("default.css") or ""
    local body = md.markdown(content)

    -- Extract title from first heading
    local title = body:match("<h1>(.-)</h1>") or body:match("<h2>(.-)</h2>") or "Document"

    return string.format([[<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>%s</title>
    <style>%s</style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
</head>
<body>
%s
<script>hljs.highlightAll();</script>
</body>
</html>]], title, css, body)
end

-- Parse HTTP request
local function parse_request(data)
    local method, path = data:match("^(%S+)%s+(%S+)")
    if path == "/" then path = "/test.md" end
    return method, path:sub(2) -- remove leading /
end

-- Build HTTP response
local function response(status, ctype, body)
    return string.format(
        "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s",
        status, ctype, #body, body
    )
end

-- Main server
local server = assert(socket.bind("*", PORT))
print(string.format("Serving on http://localhost:%s", PORT))

while true do
    local client = server:accept()
    client:settimeout(5)

    local data = client:receive("*l")
    if data then
        local method, path = parse_request(data)
        print(method, path)

        local content = read_file(path)
        if content then
            if path:match("%.md$") then
                content = render_markdown(content)
            end
            client:send(response("200 OK", content_type(path), content))
        else
            client:send(response("404 Not Found", "text/plain", "Not found: " .. path))
        end
    end

    client:close()
end
