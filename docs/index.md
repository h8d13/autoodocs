# Documentation

# Autoodocs

A lightweight documentation generator that extracts tagged comments from source files.
Inspired by @tsoding `nob.h` autodocs.

Supports `--`, `//`, `#`, `;`, `%`, `/* */`, `<!-- -->`, `--[[ ]]`, `{- -}`, `"""`, `'''`

Skips (and stores) the whole comment block until next code line.

## Features

- Extracts `@gen`, `@def`, `@chk`, `@run`, `@err` tagged comments
- Cross-references with `@src:file:line` auto-resolving anchors
- Subject line counts with `:N` syntax
- GitHub-style callouts (`!n` NOTE, `!t` TIP, `!w` WARN, `!c` CAUTION)
- Respects `.gitignore` and `.somefolder/` ignores
- Generates markdown with HTML output via bundled converter

## Installation

Requires: **Lua 5.x** and **git**

Clone to a hidden folder so autoodocs doesn't document itself:

```sh
cd /yourprojectroot/
git clone https://github.com/h8d13/autoodocs .autoodocs/
```

## Configuration

Edit `.autoodocs/config.lua` to adjust settings:

```lua
return {
    scan_dir = ".",       -- Directory to scan for tagged comments
    out_dir  = "docs",    -- Output directory for generated docs
    stats    = true,      -- Show statistics after generation
    check    = true,      -- Validate subject line counts
}
```

(Optionally) Create a branch named `pages`.

## Usage

```sh
mkdir -p docs
lua .autoodocs/autoodocs.lua . docs (-s) (-c)  # -s stats, -c validate counts
lua .autoodocs/markdown.lua docs/*.md          # convert to HTML
```

> Max comment length `87` chars, `-c` check needs a blank line at subject `n+1`

You can also adapt the `build.lua` to your structure. Or use pre-commit hook:

## GitHub Pages

Go to repo `Settings` > `Pages` > `Deploy from branch` > `pages` > `/docs`

Or directly from root `/` or without a specific branch.

---



<!-- NAV
[build.lua](build-lua.html)
[markdown.lua](markdown-lua.html)
[default.css](default-css.html)
[config.lua](config-lua.html)
[autoodocs.lua](autoodocs-lua.html)
[>lib]
[parser.lua](parser-lua.html)
[utils.lua](utils-lua.html)
[render.lua](render-lua.html)
[<]
-->
<!-- REPO:https://github.com/h8d13/autoodocs -->
