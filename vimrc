"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"               ██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"               ██║   ██║██║██╔████╔██║██████╔╝██║     
"               ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║     
"                ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Packages required:
" 	1. Plug

" Table of Contents
" ==========================================
" 1. General Settings				Ln: 34
" 2. Interface and Display			Ln: 49
" 3. Search							Ln: 68
" 4. Identation and Formatting		Ln: 75
" 5. Files and Backup				Ln: 86
" 6. Visual and GUI					Ln: 94
" 7. Performance					Ln: 104
" 8. Splts and Windows				Ln: 110
" 9. Miscellaneous					Ln: 116
" 10. Key Mappings					Ln: 126
" 	10.1 Normal						Ln: 129
" 	10.2 Insert						Ln: 167
" 	10.3 Visual						Ln: 212
" 	10.4 Command					Ln: 217
" 11. Plugins						Ln: 223
" 	11.1 Plug Install				Ln: 226
"	11.2 Nerd Tree					Ln: 245
"	11.3 Airline					Ln: 253
"	11.4 YouCompleteMe				Ln: 291
" ==========================================

"1. General Settings 
"set nocompatible       " Disable Vi compatibility mode
set encoding=utf-8     " Set default encoding to UTF-8
set fileencoding=utf-8 " Set file-specific encoding to UTF-8
set undofile           " Enable persistent undo
"set swapfile           " Enable swap files for recovery
"set clipboard=unnamedplus " Use system clipboard for yank, delete, paste, etc.
set wildmenu           " Enable command-line completion
set wildmode=list:longest " Make wildmenu behave like similar to Bash completion.
set wildignore=*.o,*.a,*.class,*.swp,*.swo,*.swn,*.pyc,*.pyo " Ignore these files during completion
set ruler              " Show the cursor position all the time
set showcmd            " Show partial commands in the last line
set cmdheight=2        " Set the command line height to 2
set history=500       " Remember more commands in history

" 2. Interface and Display 
set number             " Show absolute line numbers
set relativenumber     " Show relative line numbers
"set cursorline         " Highlight the current line
set showmatch          " Highlight matching parentheses
set scrolloff=10        " Keep 8 lines visible above/below cursor
set sidescrolloff=8    " Keep 8 columns visible left/right of cursor
"set signcolumn=yes     " Always show the sign column (used by diagnostics)
set termguicolors      " Enable 24-bit RGB colors
"set colorcolumn=80     " Highlight the 80th column (useful for line length)
"set background=dark    " Set background for dark theme
set statusline=			" Clear status line when vimrc is reloaded.
"set statusline+=%f\ %F\ %M\ %Y\ %R " Status line left side.
"set statusline=%f\ %m\ %r\ %h\ %w\ %y\ %=%l,%c\ %p%%
set statusline+=%=		" Use a divider to separate the elft side from the right side.
set laststatus=2       " Always show the status line
set showtabline=2      " Always show the tab line.
set showmode			" Show the mode you are on the last line

" 3. Search
set hlsearch           " Highlight search results
set incsearch          " Incremental search that shows matches as you type
set ignorecase         " Ignore case in search patterns
set smartcase          " Override ignorecase if search pattern contains uppercase
"set gdefault           " Apply substitution globally by default

" 4. Indentation and Formatting
set tabstop=4          " Set width of tab character
set shiftwidth=4       " Set indentation width
"set expandtab          " Use spaces instead of tabs
set autoindent         " Auto-indent new lines to match the previous line
set smartindent        " Enable smart indentation for code
set smarttab           " Insert tabs based on shiftwidth
"set wrap               " Enable line wrapping
"set textwidth=80       " Automatically wrap lines at 80 characters
"set formatoptions+=cro " Enable auto-wrap, remove comments on auto-wrap

" 5. Files and Backup
set nobackup
"set backupdir=~/.vim/backup//    " Set backup directory
"set directory=~/.vim/swap//      " Set swap file directory
"set undodir=~/.vim/undo//        " Set undo file directory
"set backup                      " Enable backups
"set writebackup                 " Backup before overwriting files

" 6. Visual and GUI
set guifont=Menlo:h12       " Set GUI font
"set mouse=a                     " Enable mouse in all modes
set linebreak                   " Don't break words on wrap
set showbreak=↪                 " Show symbol for wrapped lines
set list                        " Show invisible characters
set listchars=tab:▸\ ,trail:·,extends:❯,precedes:❮,nbsp:␣ " Define list characters
set foldmethod=syntax           " Fold based on syntax
set foldlevelstart=99           " Open most folds by default

" 7. Performance
set lazyredraw        " Don't redraw while executing macros
set timeoutlen=500    " Time to wait for a mapped sequence to complete
set updatetime=300    " Faster completion (default 4000ms)
set t_Co=256          " Support 256 colors

" 8. Splits and Windows
set splitright        " Vertical split to the right
set splitbelow        " Horizontal split below
set equalalways       " Equalize window dimensions when resizing
set winminheight=0    " Minimize window height when opening splits

" 9. Miscellaneous
syntax on
set completeopt=menuone,noinsert,noselect " Better completion experience
set shortmess+=c      " Avoid showing extra messages when using completion
set autowrite         " Automatically save before commands like :next and :make
set hidden            " Enable background buffers
"set whichwrap+=<,>,[] " Allow moving to next/previous line with arrow keys
set backspace=indent,eol,start " Make backspace work like most editors
set virtualedit=onemore " Allow cursor beyond the end of line

" 10. Key Mappings
let maplead = "\\"	" Set the backslash as the leader key.

" 10.1
" 					"
"	Normal Remap	"
"					"
"Press || to jump back to the last cursor position.
nnoremap <leader>\ '' 

" Clears highlights
nnoremap <C-c> :noh<CR>

" Press the space bar to type the : character in command mode.
nnoremap <space> :

" Center the cursor vertically when moving to the next word during a search.
nnoremap n nzz
nnoremap N Nzz

" Yank from cursor to the end of line.
nnoremap Y y$

" Makes it centers the screen on page changes
" Half page
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
" Full page
nnoremap <C-b> <C-b>zz
nnoremap <C-f> <C-f>zz

" Navigate the splut view easier by pressing CTRL + h,j,k,l.
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" NERDTree Mappings
"  Map the F3 key to toggle NERDTree open and close
nnoremap <c-t> :NERDTreeToggle<cr>

" 10.2
" 					"
"	Insert Remaps	"
"					"

" Goes into search mode
inoremap <C-s> <Esc>/
" Clears highlights - Think c as in clear
inoremap <C-c> <C-o>:noh<CR>

" Moves to beginning of a line
inoremap <C-I> <C-o>0
" Moves to end of a line
inoremap <C-A> <C-o>$
"
" Move forward a word
inoremap <C-w> <C-o>w
" Move back to the start of a word
inoremap <C-b> <C-o>b

" Move to end of a word
inoremap <C-e> <C-o>e<C-o>

" Move forward to matching character - Think m as match
inoremap <C-n> <C-o>f
" Move backward to matching character - Think p as previous
inoremap <C-p> <C-o>F

" Undo - Think u as in undo
inoremap <C-u> <C-o>u
" Redo - Think ru as in re-undo
inoremap <C-r><C-u> <C-o><C-r>
" Delete word - Think d as delete word
inoremap <C-d> <C-o>ciw
" Delete paraenthesis 
inoremap <C-)> <C-o>ci(
" Delete brackets- Think sb as square brackets
inoremap <C-s><C-b> <C-o>ci[
" Delete braces - Think cb as curly braces
inoremap <C-c><C-b> <C-o>ci{
" Deletes angle brackets - Think ab as angle brackets
inoremap <C-a><C-b> <C-o>ci<

inoremap <Tab> <Tab>

" 10.3
" 					"
"	Visual Remaps	"
"					"

" 10.4
" 					"
"	Command Remaps	"
"					"


" 11. Plugins
filetype plugin on

"11.1
"					"
"	Plug Installs	"
"					"
call plug#begin('~/.vim/plugged')
	" VIM UI
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	" Git UI
	Plug 'airblade/vim-gitgutter'
	" Git commands 
	Plug 'tpope/vim-fugitive'
	" Autocomplete
	Plug 'ycm-core/YouCompleteMe'
	" Auto closes (), {}, [], "", '', `` 
	Plug 'jiangmiao/auto-pairs' 
	" Assembly code LSP
	Plug 'Shirk/vim-gas'
	" LSP & Linter
	Plug 'dense-analysis/ale'
	" File Tree
	Plug 'preservim/nerdtree'
	" Theme
	Plug 'ghifarit53/tokyonight-vim'
call plug#end()
colorscheme tokyonight   " Changes color scheme here
" Transparent background
"hi Normal guibg=NONE ctermbg=NONE

" 11.2
"						"
"	NERD Tree Config	"
"						"

" Have nerdtree ignore certain files and directories.
let NERDTreeIgnore=[]

" 11.3
" 					"
" 	Airline Config	"
" 					"
" Set a theme for Airline
let g:airline_theme = 'tokyonight' " You can choose from themes like 'dark', 'bubblegum', 'minimalist', etc.

" Show the current mode in the status line
let g:airline#extensions#mode#enabled = 1

" Display the branch name if you are in a Git repository
let g:airline#extensions#branch#enabled = 1

" Show file type and encoding
let g:airline#extensions#filetype#enabled = 1
let g:airline#extensions#filetype#show_encoding = 1
let g:airline#extensions#filetype#show_filetype = 1

" Add a separator between sections
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type = 1

" Configure the sections of the status line
let g:airline_section_b = '%{FugitiveHead()}'  " Displays the Git branch, use Fugitive plugin if installed

let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

let g:airline_section_c = '%f %h%w %m'  " Displays file path and status
let g:airline_section_x = '%{&filetype}'  " Displays file type
let g:airline_section_y = '%{&encoding}'  " Displays encoding
let g:airline_section_z = '%l:%c'  " Displays line and column numbers

" Enable the tabline (for showing buffers/tabs)
let g:airline#extensions#tabline#enabled = 1

" 11.4
"							"
"	YouCompleteMe Config	"
"							"
let g:ycm_use_clangd = 1
let g:ycm_language_server = []
let g:ycm_auto_trigger = 1
let g:ale_completion_enabled = 1

" 11.5
"  				"
"  	VIM GUTTER	"
"  				"
" Enable vim-gutter by default
let g:gutter_enable = 1
" Character markers
let g:gutter_sign_added = '▶'
let g:gutter_sign_modified = '✎'
let g:gutter_sign_removed = '✗'

" Filetype Detection
" Set filetype for specific file extensions
autocmd BufRead,BufNewFile ECE178/*.s set filetype=nios2

" Set filetype for files with specific patterns
autocmd BufRead,BufNewFile ECE178/*.s set filetype=nios2

