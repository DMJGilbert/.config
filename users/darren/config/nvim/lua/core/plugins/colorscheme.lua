return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
	{
		"catppuccin/nvim",
		priority = 1000,
		name = "catppuccin",
		config = function()
			local catppuccin = require("catppuccin")
			local colors = require("catppuccin.palettes").get_palette()
			catppuccin.setup({
				flavour = "frappe",
				dim_inactive = {
					enabled = true,
					shade = "dark",
					percentage = 0.15,
				},
				transparent_background = true,
				term_colors = true,
				no_italic = true,
				styles = {
					comments = {},
					conditionals = {},
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
				integrations = {
					treesitter = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							-- errors = { "italic" },
							-- hints = { "italic" },
							-- warnings = { "italic" },
							-- information = { "italic" },
						},
						underlines = {
							-- errors = { "underline" },
							-- hints = { "underline" },
							-- warnings = { "underline" },
							-- information = { "underline" },
						},
					},
					barbecue = {
						dim_dirname = true,
						bold_basename = true,
						dim_context = false,
					},
					hop = true,
					cmp = true,
					gitgutter = true,
					gitsigns = true,
					telescope = true,
					noice = true,
					notify = true,
				},
				color_overrides = {},
				highlight_overrides = {},
				custom_highlights = {
					CursorLine = { bg = colors.crust },
					CursorColumn = { fg = colors.text },
				},
			})
			vim.api.nvim_set_hl(0, "FloatBorder", { bg = colors.mantle, fg = colors.surface })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.base })
		end,
	},
}
