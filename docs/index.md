# Documentation

# Autoodocs

A lightweight documentation generator that extracts tagged comments from source files.

## Features

- Extracts `@gen`, `@def`, `@chk`, `@run`, `@err` tagged comments
- Skips the whole comment block until next code line
- Cross-references with `@src:file:line` auto-resolving anchors
- Subject line counts with `:N` syntax
- GitHub-style callouts (`!n` NOTE, `!t` TIP, `!w` WARN, `!c` CAUTION)
- Generates markdown with HTML output via bundled converter

## Usage

Create a branch named `pages`.

Go to repo `Settings` > `Pages` > `Deploy from branch` > `pages` > `/docs`

```sh
lua autodocs.lua [scan_dir] [out_dir] [-s]  # generate markdown
lua markdown.lua docs/file.md               # convert to HTML

# do both at once
lua build.lua                               # run full pipeline
```


<!-- NAV
[build.lua](build-lua.html)
[markdown.lua](markdown-lua.html)
[autodocs.lua](autodocs-lua.html)
[default.css](default-css.html)
[>lib]
[parser.lua](parser-lua.html)
[utils.lua](utils-lua.html)
[render.lua](render-lua.html)
[<]
-->
