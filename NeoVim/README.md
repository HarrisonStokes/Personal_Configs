# Key mappings
\<leader> = \<space>

## Navigation and Movement
### Cursor Postion and History
\<leader>\ - Jump back to last cursor position.

### Page and Screen Movement
\<C-d> - Half page down.
\<C-u> - Half page up.
\<C-f> - Full page down.
\<C-b> - Full page up.

### Window Navigation
\<C-h> - Move to the left window.
\<C-l> - Move to the right window.
\<C-j> - Move to the bottom window.
\<C-k> - Move to the up window.

### Insert Mode Navigation
\<C-I> - Move to beginning of line.\n
\<C-A> - Move to end of line.\n
\<C-w> - Move forward one word.\n
\<C-b> - Move back to start of word.\n
\<C-e> - Move to end of word.\n

### Character Finding
\<C-n> - Find next character while in Insert mode.\n
\<C-p> - Find previous character while in Insert mode.\n
: - Repeat last f/F/t/T character search.\n

## Search and Highlighting
### Search Navigation
n - Next search result.\n
N - Previous search result.\n


### Search Entry
\<C-s> - Exit insert and start search.\n

### Clear Highlights
\<C-c> - Clear search highlights.\n
\<C-c> - Clear highlights while in insert.\n

## Command Mode Access
### Command Entry
; - Enter command mode.

## Text Editing and Manipulation
### Copy/Yank Operations
Y - Yank from cursor to end of line.

### Delete Operations (Insert Mode)
\<C-d> - Delete current word.\n
\<C-)> - Delete inside parentheses.\n
\<C-s>\<C-b> - Delete inside square brackets.\n
\<C-c>\<C-b> - Delete inside curly braces.\n
\<C-a>\<C-b> - Delete inside angle brackets.\n


### Undo/Redo (Insert Mode)
\<C-u> - Undo.\n
\<C-r>\<C-u> - Redo.\n

### Line Movement (Visual Mode)
J - Move selected lines down.
K - Move selected lines up.

### Indentation (Visual Mode)
< - Indent left.
\> - Indent right.


## Mode Switching
### Exit Insert Mode
jk - Exit to normal mode.\n

### Exit Terminal Mode
\<Esc> - Exit terminal mode to normal.\n

### File Operations
\<leader>w - Save file.\n
\<leader>q - Quit.\n
\<leader>z - Save file and quit.\n


## Nvim Tree
\<leader>e - Toggles file tree.
\<leader>ef - Toggles find file.

## Autocompletion
\<C-j> - Move down in completion menu.
\<C-k> - Move up in completion menu.
\<C-f> - Scroll documentation window down.
\<C-b> - Scroll documentation window up.
\<C-Space> - Force show completion menu.
\<C-e> - Close completion menu.
\<Enter> - Select completion.

## Git Signs
\<leader>hs - Stages the current git change (hunk) under your cursor. Useful to stage specific lines of code.
\<leader>hu - Unstages a previously staged hunk.
\<leader>hr - Undoes/reverts the current git change back to the original version.
\<leader>hS -Stages all changes in the current file/buffer.
\<leader>hR - Reverts all changes in the current file/buffer.
\<leader>hp - Shows a popup with the diff for the current hunk.
\<leader>hb - Shows who last modified the current line and when.
\<leader>hd - Opens a split view showing hte current file vs the git version.

## Telescope
\<leader>ff - Opens a fuzzy finder to search for files by name in your project.
\<leader>fg - Searches for text content across all files in your project.
\<leader>fb - Shows all currently open files/buffers and lets you switch between them.
\<leader>fh - Seaches through Neovim's help documentation.
\<leader>fr - Shows recently opened files.

### Result Navigation
\<C-k> - Move down
\<C-j> - Move up
\<Enter> - Select/open item
\<Esc> - Cancel and close
\<Tab> - Toggle selection (for multi-select operations)

### Getting Help
\<leader>fh - type "telescope" to pull up Telescope features.
\<leader>fh - type "lsp" to pull up LSP commands.
