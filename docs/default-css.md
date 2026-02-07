# default.css

`~/Desktop/autoodocs/default.css`

Basic markdown stylesheet with GitHub-style sidebar

## <a id="def"></a>Defines

### <a id="def-1"></a>Color scheme variables

`~/Desktop/autoodocs/default.css:3`

```css
:root {
    --bg: #fff;
    --fg: #333;
    --fg-muted: #555;
    --fg-subtle: #666;
    --border: #eee;
    --border-strong: #ddd;
    --sidebar-bg: #f9f9f9;
    --hover-bg: #e9e9e9;
    --active-bg: #e1f0ff;
    --code-bg: #f4f4f4;
    --link: #0366d6;
    --note: #0969da; --note-bg: #ddf4ff;
    --tip: #1a7f37; --tip-bg: #dafbe1;
    --important: #8250df; --important-bg: #fbefff;
    --warning: #9a6700; --warning-bg: #fff8c5;
    --caution: #cf222e; --caution-bg: #ffebe9;
}

@media (prefers-color-scheme: dark) {
    :root {
        --bg: #0d1117;
        --fg: #c9d1d9;
        --fg-muted: #8b949e;
        --fg-subtle: #6e7681;
        --border: #21262d;
        --border-strong: #30363d;
        --sidebar-bg: #161b22;
        --hover-bg: #21262d;
        --active-bg: #1f3a5f;
        --code-bg: #161b22;
        --link: #58a6ff;
        --note: #58a6ff; --note-bg: #121d2f;
        --tip: #3fb950; --tip-bg: #12261e;
        --important: #a371f7; --important-bg: #1f1832;
        --warning: #d29922; --warning-bg: #272115;
        --caution: #f85149; --caution-bg: #2d1b1b;
    }
}

/* @def:3 Box sizing reset */
* {
    box-sizing: border-box;
}
```

### <a id="def-2"></a>Layout container

`~/Desktop/autoodocs/default.css:59`

```css
.container {
    display: flex;
    max-width: 1400px;
    margin: 0 auto;
}
```

### <a id="def-3"></a>Sidebar navigation panel

`~/Desktop/autoodocs/default.css:66`

```css
.sidebar {
    width: 280px;
    min-width: 280px;
    height: 100vh;
    position: sticky;
    top: 0;
    padding: 1.5em;
    border-right: 1px solid var(--border);
    overflow-y: auto;
    background: var(--sidebar-bg);
}
```

### <a id="def-4"></a>Main content area

`~/Desktop/autoodocs/default.css:169`

```css
.content {
    flex: 1;
    min-width: 0;
    padding: 0.1em 3em;
    max-width: 900px;
}
```

### <a id="def-5"></a>Heading styles

`~/Desktop/autoodocs/default.css:177`

```css
h1, h2, h3, h4, h5, h6 {
    margin-top: 0.3em;
    margin-bottom: 0.5em;
    font-weight: 600;
    line-height: 1.25;
}

h1 { font-size: 2em; border-bottom: 1px solid var(--border); padding-bottom: 0.3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid var(--border); padding-bottom: 0.3em; }
h3 { font-size: 1.25em; }
h4 { font-size: 1em; }

.content > h2:first-child {
    margin-top: 0;
}
```

### <a id="def-6"></a>Code and pre blocks

`~/Desktop/autoodocs/default.css:222`

```css
code {
    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
    font-size: 0.9em;
    color: var(--fg);
    background: var(--code-bg);
    padding: 0.2em 0.4em;
    border-radius: 3px;
}

pre {
    color: var(--fg);
    background: var(--code-bg);
    padding: 1em;
    overflow-x: auto;
    border-radius: 4px;
}

pre code {
    background: none;
    padding: 0;
}
```

### <a id="def-7"></a>GitHub-style callout boxes

`~/Desktop/autoodocs/default.css:289`

```css
.callout {
    border-left: 4px solid;
    margin: 1em 0;
    padding: 0.5em 1em;
    border-radius: 4px;
}

.callout-title {
    font-weight: 600;
    margin-bottom: 0.25em;
}

.callout p { margin: 0.25em 0; }

.callout-note { border-color: var(--note); background: var(--note-bg); }
.callout-note .callout-title { color: var(--note); }

.callout-tip { border-color: var(--tip); background: var(--tip-bg); }
.callout-tip .callout-title { color: var(--tip); }

.callout-important { border-color: var(--important); background: var(--important-bg); }
.callout-important .callout-title { color: var(--important); }

.callout-warning { border-color: var(--warning); background: var(--warning-bg); }
.callout-warning .callout-title { color: var(--warning); }

.callout-caution { border-color: var(--caution); background: var(--caution-bg); }
.callout-caution .callout-title { color: var(--caution); }
```

### <a id="def-8"></a>Mobile responsive breakpoint

`~/Desktop/autoodocs/default.css:319`

```css
@media (max-width: 900px) {
    .container {
        flex-direction: column;
    }

    .sidebar {
        width: 100%;
        height: auto;
        position: relative;
        border-right: none;
        border-bottom: 1px solid var(--border);
    }

    .content {
        padding: 1.5em;
    }
}
```

