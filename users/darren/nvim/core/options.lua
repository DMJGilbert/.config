-- Map leader to space
vim.g.mapleader = " "

-- =============================================================================
-- = Theming and Looks =
-- =============================================================================
vim.o.termguicolors = true
vim.o.statuscolumn = "%s%=%{&nu?(v:relnum?v:relnum:v:lnum):''} "
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.guicursor = "i:block"
vim.opt.laststatus = 0

-- =============================================================================
-- = Options =
-- =============================================================================
-- Completion options
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.updatetime = 100 -- Faster completion and CursorHold events (default 4000ms)

-- Search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = true
vim.opt.inccommand = "split"

-- Indent options (4 spaces, common for most languages)
vim.o.tabstop = 4
vim.o.shiftwidth = 0 -- Use tabstop value
vim.o.softtabstop = 4
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartindent = true

-- Line options
vim.o.cursorline = true
vim.o.showmatch = true
vim.o.showbreak = "+++"
vim.o.textwidth = 120 -- Max line width for formatting (gq)
vim.o.scrolloff = 10 -- Keep 10 lines visible above/below cursor
vim.wo.linebreak = true
vim.wo.colorcolumn = "100" -- Visual guide at column 100

-- Move swapfiles and backupfiles to ~/.cache
vim.o.directory = os.getenv("HOME") .. "/.cache/nvim"
vim.o.backup = true
vim.o.backupdir = os.getenv("HOME") .. "/.cache/nvim"

-- Enable undo features, even after closing vim
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.cache/nvim"
vim.o.undolevels = 10000 -- Maximum number of undo steps

-- Lazy redraw ()
vim.o.lazyredraw = false

-- Buffers/Tabs/Windows
vim.o.hidden = false

-- Set spelling
vim.o.spell = true
vim.o.spelloptions = "camel"
vim.o.spellcapcheck = ""
vim.o.fileformats = "unix,mac,dos"

-- Mouse support
-- vim.o.mouse = "a"

-- backspace behaviour
vim.o.backspace = "indent,eol,start"

-- Status line
vim.o.showmode = false

-- Autoreload changed files
vim.o.autoread = true

-- Make system clipboard defualt
-- vim.o.clipboard = "unnamedplus"

-- Better display
vim.o.cmdheight = 0

-- Wrap lines when moving left and right
vim.cmd("set whichwrap+=<,>,[,],h,l")

-- Setup treesitter for code folding (using Neovim's built-in foldexpr)
vim.o.foldcolumn = "1"
vim.o.foldenable = true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99 -- Start with all folds open
--
vim.cmd("set foldtext=getline(v:foldstart).'...'.trim(getline(v:foldend))")
vim.opt.fillchars = { fold = " " }
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Split options
vim.opt.splitright = true
vim.opt.splitbelow = true
