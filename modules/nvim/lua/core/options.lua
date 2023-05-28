-- Map leader to space
vim.g.mapleader = " "

-- =============================================================================
-- = Theming and Looks =
-- =============================================================================
vim.o.termguicolors = true
vim.o.statuscolumn = "%=%{&nu? (v:relnum?v:relnum:v:lnum):''}%C "
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
vim.o.updatetime = 100

-- Search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = true

-- Indent options
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- Line options
vim.o.cursorline = true
vim.o.showmatch = true
vim.o.showbreak = "+++"
vim.o.textwidth = 120
vim.o.scrolloff = 10
vim.wo.linebreak = true
vim.wo.colorcolumn = "100"

-- Move swapfiles and backupfiles to ~/.cache
vim.o.directory = os.getenv("HOME") .. "/.cache/nvim"
vim.o.backup = true
vim.o.backupdir = os.getenv("HOME") .. "/.cache/nvim"

-- Enable undo features, even after closing vim
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.cache/nvim"
vim.o.undolevels = 10000

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
vim.o.mouse = "a"

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

-- Setup treesitter for code folding
-- vim.o.foldcolumn = "1"
-- vim.o.foldenable = true
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.o.foldlevel = 10
--
-- vim.cmd("set foldtext=getline(v:foldstart).'...'.trim(getline(v:foldend))")
-- -- vim.opt.fillchars = { fold = " " }
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Split options
vim.opt.splitright = true
vim.opt.splitbelow = true
