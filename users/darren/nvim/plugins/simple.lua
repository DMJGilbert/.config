-- Simple plugin setups that don't need separate files

-- Treesitter context
require("treesitter-context").setup({})

-- Crates
require("crates").setup({})

-- Todo comments
require("todo-comments").setup({
	keywords = {
		TODO = { alt = { "todo", "unimplemented" } },
	},
	highlight = {
		pattern = {
			[[.*<(KEYWORDS)\s*:]],
			[[.*<(KEYWORDS)\s*!\(]],
		},
		comments_only = false,
	},
	search = {
		pattern = [[\b(KEYWORDS)(:|!\()]],
	},
})
vim.keymap.set("n", "<leader>t", ":TodoTelescope keywords=TODO,FIX<cr>", { desc = "Open TODO list" })

-- Barbecue
require("barbecue").setup({
	theme = "catppuccin",
})

-- Undotree
vim.keymap.set("n", "<leader>u", function()
	vim.cmd.UndotreeToggle()
end, { desc = "Open UndoTree" })

-- Autopairs
require("nvim-autopairs").setup({})

-- Surround
require("nvim-surround").setup({})

-- Mini indentscope
local indentScope = require("mini.indentscope")
indentScope.setup({
	draw = {
		delay = 0,
		animation = indentScope.gen_animation.none(),
	},
})

-- Vim commentary
vim.cmd("autocmd FileType dart setlocal commentstring=//\\ %s")

-- Colorizer
require("colorizer").setup({
	filetypes = {
		"*",
		"!TelescopePrompt",
		"!TelescopeResults",
		"!help",
	},
	user_default_options = {
		RGB = true,
		RRGGBB = true,
		names = false,
		RRGGBBAA = true,
		AARRGGBB = false,
		rgb_fn = true,
		hsl_fn = true,
		css = true,
		css_fn = false,
		mode = "background",
		tailwind = true,
		virtualtext = "■",
	},
	buftypes = {
		"*",
		"!prompt",
		"!popup",
	},
})

vim.cmd(
	[[autocmd ColorScheme * lua package.loaded['colorizer'] = nil; require('colorizer').setup(); require('colorizer').attach_to_buffer(0)]]
)

-- Hardtime
require("hardtime").setup({
	disabled_filetypes = { "NvimTree", "lazy" },
	disabled_keys = {
		["<Up>"] = {},
		["<Down>"] = {},
		["<Left>"] = {},
		["<Right>"] = {},
	},
})

-- Coverage
local colors = require("catppuccin.palettes").get_palette()
require("coverage").setup({
	commands = true,
	highlights = {
		covered = { fg = colors.green },
		uncovered = { fg = colors.red },
		partial = { fg = colors.pink },
	},
	signs = {
		covered = { hl = "CoverageCovered", text = "▏" },
		partial = { hl = "CoveragePartial", text = "▌" },
		uncovered = { hl = "CoverageUncovered", text = "█" },
	},
	summary = {
		min_coverage = 0.0,
	},
	lang = {},
})
vim.keymap.set("n", "<leader>c", "<cmd>Coverage<cr>", { desc = "Load and display coverage" })
