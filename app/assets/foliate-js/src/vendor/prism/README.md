# Prism.js Code Syntax Highlighting

This directory contains the Prism.js library for code syntax highlighting in Anx Reader.

## Directory Structure

```
prism/
├── prism-core.min.js          # Core Prism.js library
├── prism-autoloader.min.js    # Automatic language loading plugin
├── components/                 # Language definition files (62 languages)
│   ├── prism-javascript.min.js
│   ├── prism-python.min.js
│   ├── prism-java.min.js
│   └── ... (62 files total)
├── themes/                     # CSS themes (12 themes)
│   ├── prism-default.min.css
│   ├── prism-vs-dark.min.css
│   ├── prism-one-dark.min.css
│   └── ... (12 files total)
└── download_components.sh      # Script to download additional languages
```

## Supported Languages (62)

The following languages are included for offline use:

### Web Development
- JavaScript, TypeScript, JSX, TSX
- HTML/XML (markup), CSS, Sass, SCSS, Less
- PHP, PHP-Extras
- JSON, YAML, TOML
- Markdown, LaTeX

### System & Scripting
- Bash, Shell Session, PowerShell, Batch
- Python, Ruby, Perl, Lua, R

### Compiled Languages
- C, C++, C#, Objective-C
- Java, Kotlin, Scala, Groovy
- Go, Rust, Swift, Dart

### Functional Languages
- Haskell, Elixir, Erlang, Julia

### Database
- SQL, PL/SQL, MongoDB

### Configuration & DevOps
- Docker, Git, Diff
- Nginx, Makefile
- INI, Properties

### Other
- GraphQL, Protobuf
- Regex, HTTP
- Visual Basic, VB.NET

## Themes (12)

### Light Themes (4)
1. **Default** - Classic Prism theme
2. **GitHub** - GitHub-style highlighting
3. **One Light** - Atom One Light theme
4. **Material Light** - Material Design light theme

### Dark Themes (8)
1. **VS Dark** - Visual Studio Code dark theme
2. **One Dark** - Atom One Dark theme
3. **Dracula** - Popular Dracula theme
4. **Material Dark** - Material Design dark theme
5. **Nord** - Nord color palette
6. **Night Owl** - Night Owl theme
7. **Solarized Dark** - Solarized dark variant
8. **Atom Dark** - Atom editor dark theme

## How It Works

1. **Automatic Detection**: When a code block is detected, Prism.js automatically identifies the language
2. **Local Loading**: The autoloader loads the required language file from `components/` folder
3. **Offline Support**: All 62 language files are pre-downloaded for offline use
4. **No Network Required**: Everything works without internet connection

## Adding More Languages

If you need additional languages not included in the default set:

1. Visit: https://github.com/PrismJS/prism/tree/master/components
2. Download the required `prism-{language}.min.js` file
3. Place it in the `components/` folder

Or use the included download script:

```bash
cd assets/foliate-js/src/vendor/prism
./download_components.sh
```

## Version

Current version: **Prism.js 1.29.0**

## Total Size

- Core + Autoloader: ~13 KB
- Themes (12 files): ~30 KB
- Languages (62 files): ~272 KB
- **Total: ~315 KB**

## References

- Official Website: https://prismjs.com/
- GitHub: https://github.com/PrismJS/prism
- Documentation: https://prismjs.com/docs/
- Language List: https://prismjs.com/#supported-languages
