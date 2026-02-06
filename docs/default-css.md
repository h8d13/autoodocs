# default.css

`~/Desktop/autoodocs/default.css`

Basic markdown stylesheet with GitHub-style sidebar

## <a id="def"></a>Defines

### <a id="def-1"></a>Box sizing reset

`~/Desktop/autoodocs/default.css:3`

```css
* {
    box-sizing: border-box;
}
```

### <a id="def-2"></a>Layout container

`~/Desktop/autoodocs/default.css:17`

```css
.container {
    display: flex;
    max-width: 1400px;
    margin: 0 auto;
}
```

### <a id="def-3"></a>Sidebar navigation panel

`~/Desktop/autoodocs/default.css:24`

```css
.sidebar {
    width: 280px;
    min-width: 280px;
    height: 100vh;
    position: sticky;
    top: 0;
    padding: 1.5em;
    border-right: 1px solid #eee;
    overflow-y: auto;
    background: #f9f9f9;
}
```

### <a id="def-4"></a>Main content area

`~/Desktop/autoodocs/default.css:125`

```css
.content {
    flex: 1;
    min-width: 0;
    padding: 0.1em 3em;
    max-width: 900px;
}
```

### <a id="def-5"></a>Heading styles

`~/Desktop/autoodocs/default.css:133`

```css
h1, h2, h3, h4, h5, h6 {
    margin-top: 0.3em;
    margin-bottom: 0.5em;
    font-weight: 600;
    line-height: 1.25;
}

h1 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
h3 { font-size: 1.25em; }
h4 { font-size: 1em; }

.content > h2:first-child {
    margin-top: 0;
}

```

### <a id="def-6"></a>Code and pre blocks

`~/Desktop/autoodocs/default.css:178`

```css
code {
    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
    font-size: 0.9em;
    background: #f4f4f4;
    padding: 0.2em 0.4em;
    border-radius: 3px;
}

pre {
    background: #f4f4f4;
    padding: 1em;
    overflow-x: auto;
```

### <a id="def-7"></a>GitHub-style callout boxes

`~/Desktop/autoodocs/default.css:243`

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

.callout-note {
    border-color: #0969da;
    background: #ddf4ff;
}
.callout-note .callout-title { color: #0969da; }

.callout-tip {
    border-color: #1a7f37;
    background: #dafbe1;
}
.callout-tip .callout-title { color: #1a7f37; }

.callout-important {
    border-color: #8250df;
    background: #fbefff;
}
.callout-important .callout-title { color: #8250df; }

.callout-warning {
    border-color: #9a6700;
    background: #fff8c5;
}
.callout-warning .callout-title { color: #9a6700; }

.callout-caution {
    border-color: #cf222e;
    background: #ffebe9;
}
.callout-caution .callout-title { color: #cf222e; }

```

### <a id="def-8"></a>Mobile responsive breakpoint

`~/Desktop/autoodocs/default.css:288`

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
        border-bottom: 1px solid #eee;
    }

    .content {
        padding: 1.5em;
    }
}
```

