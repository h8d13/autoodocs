# Autoodocs

A lightweight documentation generator that extracts tagged comments from source files.

## Features

- Extracts `@gen`, `@def`, `@chk`, `@run`, `@err` tagged comments
- Respects `.gitignore` and `.somefolder/` ignores
- Skips the whole comment block until next code line
- Cross-references with `@src:file:line` auto-resolving anchors
- Subject line counts with `:N` syntax
- GitHub-style callouts (`!n` NOTE, `!t` TIP, `!w` WARN, `!c` CAUTION)
- Generates markdown with HTML output via bundled converter

## Installation

Copy to a hidden folder so autodocs doesn't document itself:
> From `/yourprojectroot/`

```sh
git clone https://github.com/h8d13/autoodocs .autoodocs/
cp autodocs.lua markdown.lua default.css build.lua stats.awk /myproject/.autoodocs/
```

## Usage

```sh
lua .autoodocs/autodocs.lua . docs (-s)  # generate markdown optional stats
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

## GitHub Pages

Create a branch named `pages` or directly from `master | main`.

Go to repo `Settings` > `Pages` > `Deploy from branch` > `pages` > `/docs`

Or directly from root `/` or without a specific branch.
