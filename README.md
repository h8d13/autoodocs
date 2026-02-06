A lightweight documentation generator that extracts tagged comments from source files.

## Features

- Extracts `@gen`, `@def`, `@chk`, `@run`, `@err` tagged comments
- Cross-references with `@src:file:line` auto-resolving anchors
- GitHub-style callouts (`!n` NOTE, `!t` TIP, `!w` WARN, `!c` CAUTION)
- Subject line counts with `:N` syntax
- Generates markdown with HTML output via bundled converter

## Usage

```sh
lua autodocs.lua [scan_dir] [out_dir] [-s]  # generate markdown
lua markdown.lua docs/file.md               # convert to HTML
lua build.lua                               # run full pipeline
```
