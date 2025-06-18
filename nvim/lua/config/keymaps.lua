local keymap = vim.keymap.set

-- From your vimrc - Normal mode mappings
keymap("n", "<leader>\\", "''", { desc = "Jump back to last cursor position" })
keymap("n", "<C-c>", ":noh<CR>", { desc = "Clear highlights" })

-- Use semicolon for command mode (no delay) and swap with colon
keymap("n", ";", ":", { desc = "Enter command mode" })
keymap("n", ":", ";", { desc = "Repeat last f/F/t/T" })

-- Center cursor on search (from vimrc)
keymap("n", "n", "nzz", { desc = "Next search result centered" })
keymap("n", "N", "Nzz", { desc = "Previous search result centered" })

-- Yank to end of line (from vimrc)
keymap("n", "Y", "y$", { desc = "Yank to end of line" })

-- Center screen on page movements (from vimrc)
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })
keymap("n", "<C-b>", "<C-b>zz", { desc = "Full page up centered" })
keymap("n", "<C-f>", "<C-f>zz", { desc = "Full page down centered" })

-- Window navigation (from both configs)
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- File operations (from modern config)
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q!<cr>", { desc = "Quit" })
keymap("n", "<leader>z", "<cmd>wq<cr>", { desc = "Save and quit file" })

-- Insert mode mappings (from vimrc)
keymap("i", "<C-s>", "<Esc>/", { desc = "Enter search mode from insert" })
keymap("i", "<C-c>", "<C-o>:noh<CR>", { desc = "Clear highlights from insert" })

-- Insert mode navigation (from vimrc)
keymap("i", "<C-I>", "<C-o>0", { desc = "Move to beginning of line" })
keymap("i", "<C-A>", "<C-o>$", { desc = "Move to end of line" })
keymap("i", "<C-w>", "<C-o>w", { desc = "Move forward a word" })
keymap("i", "<C-b>", "<C-o>b", { desc = "Move back to start of word" })
keymap("i", "<C-e>", "<C-o>e<C-o>", { desc = "Move to end of word" })

-- Insert mode character finding (from vimrc)
keymap("i", "<C-n>", "<C-o>f", { desc = "Move forward to matching char" })
keymap("i", "<C-p>", "<C-o>F", { desc = "Move backward to matching char" })

-- Insert mode undo/redo (from vimrc)
keymap("i", "<C-u>", "<C-o>u", { desc = "Undo" })
keymap("i", "<C-r><C-u>", "<C-o><C-r>", { desc = "Redo" })

-- Insert mode delete operations (from vimrc)
keymap("i", "<C-d>", "<C-o>ciw", { desc = "Delete word" })
keymap("i", "<C-)>", "<C-o>ci(", { desc = "Delete inside parentheses" })
keymap("i", "<C-s><C-b>", "<C-o>ci[", { desc = "Delete inside square brackets" })
keymap("i", "<C-c><C-b>", "<C-o>ci{", { desc = "Delete inside curly braces" })
keymap("i", "<C-a><C-b>", "<C-o>ci<", { desc = "Delete inside angle brackets" })

-- Exit insert mode (from modern config)
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Visual mode mappings (from modern config)
keymap("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
keymap("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Terminal mode (from modern config)
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
