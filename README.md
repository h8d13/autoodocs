<!-- @gen autoodocs meta-data examples hidden within any kind of comments
for obvious reasons README.md or readme.md only support minimal tags
 -->
# Autoodocs

A lightweight documentation generator that extracts tagged comments from source files.
Inspired by @tsoding `nob.h` autodocs.

<!-- @def Feature list -->
## Features

- Extracts `@gen`, `@def`, `@chk`, `@run`, `@err` tagged comments
- Supports `--`, `//`, `#`, `;`, `%`, `/* */`, `<!-- -->`, `--[[ ]]`, `{- -}`, `"""`, `'''`
- Respects `.gitignore` and `.somefolder/` ignores
- Skips the whole comment block until next code line
- Cross-references with `@src:file:line` auto-resolving anchors
- Subject line counts with `:N` syntax
- GitHub-style callouts (`!n` NOTE, `!t` TIP, `!w` WARN, `!c` CAUTION)
- Generates markdown with HTML output via bundled converter

<!-- @chk Requires Lua 5.x and git -->
## Installation

Clone to a hidden folder so autoodocs doesn't document itself:

```sh
cd /yourprojectroot/
git clone https://github.com/h8d13/autoodocs .autoodocs/
```

<!-- @run CLI usage -->
<!-- @src:build.lua -->
## Usage

```sh
lua .autoodocs/autoodocs.lua . docs (-s)  # generate markdown optional stats
lua .autoodocs/markdown.lua docs/*.md    # convert to HTML
```

Or create a build script / pre-commit hook:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: autoodocs
        name: autoodocs
        entry: bash -c 'lua .autoodocs/build.lua && git add docs/'
        language: system
        pass_filenames: false
        always_run: true
```

<!-- @run GitHub Pages deployment -->
## GitHub Pages

Create a branch named `pages` or directly from `master | main`.

Go to repo `Settings` > `Pages` > `Deploy from branch` > `pages` > `/docs`

Or directly from root `/` or without a specific branch.
