# Modern Neovim Configuration

A feature-rich, beginner-friendly Neovim configuration built with Lua and managed by lazy.nvim. This setup transforms Neovim into a powerful IDE-like experience while maintaining the speed and efficiency that makes Neovim great.

## 🚀 Features Overview

### Core Features
- **Plugin Management**: [lazy.nvim](https://github.com/folke/lazy.nvim) for fast, lazy-loaded plugin management
- **Language Server Protocol (LSP)**: Full IDE features like autocompletion, diagnostics, and code navigation
- **Syntax Highlighting**: Advanced syntax highlighting with Tree-sitter
- **File Navigation**: Fuzzy finding and file tree explorer
- **Git Integration**: Visual git status, blame, and hunk navigation
- **Auto-completion**: Intelligent code completion with snippets
- **Modern UI**: Beautiful status line and color scheme

## 📋 Prerequisites

- **Neovim 0.9.0+** (recommended: latest stable version)
- **Git** (for plugin management)
- **A Nerd Font** (for icons) - Download from [Nerd Fonts](https://www.nerdfonts.com/)
- **ripgrep** (for live grep in Telescope): `brew install ripgrep` or equivalent
- **Node.js** (for some LSP servers)

## 🛠 Installation

1. **Backup your existing Neovim configuration** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone this configuration**:
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```
   
   The first time you start Neovim, lazy.nvim will automatically install all plugins. This may take a few minutes.

4. **Install Language Servers**:
   After plugins are installed, open Neovim and run:
   ```
   :Mason
   ```
   The configured language servers will be automatically installed.

## 🎯 Supported Languages

This configuration comes pre-configured with LSP support for:

- **C/C++** (clangd)
- **Rust** (rust-analyzer)
- **Python** (pylsp)
- **JavaScript/TypeScript** (ts_ls)
- **HTML/CSS** (html, cssls)
- **Bash** (bashls)
- **Lua** (for Neovim configuration)
- **Verilog** (treesitter only)
- **JSON, YAML, Markdown** (treesitter + basic support)

## ⌨️ Key Mappings

### Leader Key
- **Space** (` `) is the leader key

### Basic Navigation & Editing
| Key | Mode | Action |
|-----|------|--------|
| `jk` | Insert | Exit insert mode |
| `;` | Normal | Enter command mode (instead of `:`) |
| `:` | Normal | Repeat last f/F/t/T motion |
| `<C-c>` | Normal/Insert | Clear search highlights |
| `Y` | Normal | Yank to end of line |

### Window Navigation
| Key | Mode | Action |
|-----|------|--------|
| `<C-h>` | Normal | Move to left window |
| `<C-j>` | Normal | Move to bottom window |
| `<C-k>` | Normal | Move to top window |
| `<C-l>` | Normal | Move to right window |

### File Operations
| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | Normal | Save file |
| `<leader>q` | Normal | Quit |
| `<leader>z` | Normal | Save and quit |

### File Explorer (nvim-tree)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | Normal | Toggle file explorer |
| `<leader>ef` | Normal | Find current file in explorer |

### Fuzzy Finding (Telescope)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep (search in files) |
| `<leader>fb` | Normal | Find open buffers |
| `<leader>fh` | Normal | Help tags |
| `<leader>fr` | Normal | Recent files |
| `<leader>ft` | Normal | Find TODO comments |

### LSP (Language Server) Features
| Key | Mode | Action |
|-----|------|--------|
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Show references |
| `K` | Normal | Show hover information |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal/Visual | Code actions |
| `<leader>d` | Normal | Show diagnostics |
| `[d` | Normal | Previous diagnostic |
| `]d` | Normal | Next diagnostic |
| `<leader>l` | Normal | Toggle diagnostic display style |

### Git (Gitsigns)
| Key | Mode | Action |
|-----|------|--------|
| `]c` | Normal | Next git hunk |
| `[c` | Normal | Previous git hunk |
| `<leader>hs` | Normal | Stage hunk |
| `<leader>hr` | Normal | Reset hunk |
| `<leader>hS` | Normal | Stage entire buffer |
| `<leader>hR` | Normal | Reset entire buffer |
| `<leader>hp` | Normal | Preview hunk |
| `<leader>hb` | Normal | Blame line |
| `<leader>hd` | Normal | Diff this |

### TODO Comments
| Key | Mode | Action |
|-----|------|--------|
| `]t` | Normal | Next TODO comment |
| `[t` | Normal | Previous TODO comment |

### Visual Mode
| Key | Mode | Action |
|-----|------|--------|
| `J` | Visual | Move selection down |
| `K` | Visual | Move selection up |
| `<` | Visual | Indent left (keeps selection) |
| `>` | Visual | Indent right (keeps selection) |

### Insert Mode Navigation
| Key | Mode | Action |
|-----|------|--------|
| `<C-I>` | Insert | Move to beginning of line |
| `<C-A>` | Insert | Move to end of line |
| `<C-w>` | Insert | Move forward one word |
| `<C-b>` | Insert | Move back to start of word |
| `<C-e>` | Insert | Move to end of word |

## 🔧 Plugin Details

### Core Plugins

#### Plugin Manager
- **lazy.nvim**: Modern plugin manager with lazy loading for faster startup times

#### Language Server Protocol (LSP)
- **mason.nvim**: Manages installation of LSP servers, formatters, and linters
- **nvim-lspconfig**: Provides configurations for various language servers
- **mason-lspconfig.nvim**: Bridges mason and lspconfig for automatic setup

#### Completion System
- **nvim-cmp**: Autocompletion engine
- **cmp-nvim-lsp**: LSP completion source
- **cmp-buffer**: Buffer completion source
- **cmp-path**: File path completion
- **LuaSnip**: Snippet engine
- **friendly-snippets**: Collection of useful snippets

#### Syntax & Highlighting
- **nvim-treesitter**: Advanced syntax highlighting and text objects

#### File Navigation
- **telescope.nvim**: Fuzzy finder for files, buffers, and more
- **nvim-tree.lua**: File explorer sidebar

#### Git Integration
- **gitsigns.nvim**: Shows git status in the sign column and provides git commands

#### UI Enhancement
- **lualine.nvim**: Beautiful and configurable status line
- **tokyonight.nvim**: Modern dark color scheme
- **nvim-web-devicons**: File type icons

#### Productivity
- **nvim-autopairs**: Automatically pairs brackets, quotes, etc.
- **todo-comments.nvim**: Highlights and navigates TODO, FIXME, etc. comments
- **lsp_lines.nvim**: Enhanced diagnostic display

## 🎨 Customization

### Changing the Color Scheme
Edit `lua/plugins/colorscheme.lua` to use a different theme. Popular alternatives:
- `"catppuccin/nvim"`
- `"EdenEast/nightfox.nvim"`
- `"rebelot/kanagawa.nvim"`

### Adding New Language Servers
1. Open `:Mason` and install your desired language server
2. Add it to the `ensure_installed` list in `lua/plugins/lsp.lua`
3. Restart Neovim

### Modifying Key Mappings
Edit `lua/config/keymaps.lua` to change or add key mappings.

### Adding New Plugins
1. Create a new file in `lua/plugins/` (e.g., `my-plugin.lua`)
2. Follow the lazy.nvim plugin specification format:
   ```lua
   return {
     "author/plugin-name",
     config = function()
       -- Plugin setup
     end,
   }
   ```

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin version lock file
├── lua/
│   ├── config/
│   │   ├── options.lua     # Neovim settings
│   │   └── keymaps.lua     # Key mappings
│   └── plugins/
│       ├── autopairs.lua   # Auto-pairing brackets
│       ├── cmp.lua        # Completion setup
│       ├── colorscheme.lua # Color scheme
│       ├── gitsigns.lua   # Git integration
│       ├── improve-comments.lua # TODO comments
│       ├── lsp.lua        # Language servers
│       ├── lsp-virtual-text.lua # Diagnostic display
│       ├── lualine.lua    # Status line
│       ├── nvim-tree.lua  # File explorer
│       ├── telescope.lua  # Fuzzy finder
│       └── treesitter.lua # Syntax highlighting
```

## 🐛 Troubleshooting

### Plugin Issues
- Run `:Lazy` to check plugin status
- Use `:Lazy sync` to update plugins
- Use `:Lazy clean` to remove unused plugins

### LSP Issues
- Run `:LspInfo` to check LSP status
- Use `:Mason` to reinstall language servers
- Check `:checkhealth` for general health information

### Performance Issues
- Run `:checkhealth` to identify problems
- Consider lazy-loading more plugins if startup is slow

## 🚀 Getting Started Tips

1. **Start with the basics**: Learn the core navigation keys (`hjkl`, `w`, `b`, `e`)
2. **Use the file explorer**: Press `<leader>e` to toggle the file tree
3. **Search files quickly**: Use `<leader>ff` to find files by name
4. **Search content**: Use `<leader>fg` to search within files
5. **Learn LSP features**: Hover over variables with `K`, go to definitions with `gd`
6. **Use completion**: Start typing and use `<C-j>`/`<C-k>` to navigate suggestions

## 📚 Learning Resources

- **Neovim Documentation**: `:help` or [online docs](https://neovim.io/doc/)
- **Vim Motions**: Practice with `vimtutor` command
- **Lua Scripting**: [Nvim Lua Guide](https://github.com/nanotee/nvim-lua-guide)
- **Plugin Documentation**: Use `:help plugin-name` for specific plugins

## 🤝 Contributing

Feel free to submit issues and enhancement requests! This configuration is designed to be a solid foundation that you can build upon.

---

**Happy coding!** 🎉
