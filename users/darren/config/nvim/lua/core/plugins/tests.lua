return {
	"andythigpen/nvim-coverage",
	lazy = false,
	requires = "nvim-lua/plenary.nvim",
	keys = {
		{
			"<leader>c",
			"<cmd>Coverage<cr>",
			desc = "Load and display coverage",
		},
	},
	config = function()
		-- local colors = require("catppuccin.palettes").get_palette()
		require("coverage").setup({
			commands = true, -- create commands
			highlights = {
				-- customize highlight groups created by the plugin
				covered = { fg = "#75e36b" }, -- supports style, fg, bg, sp (see :h highlight-gui)
				uncovered = { fg = "#F07178" },
			},
			signs = {
				-- use your own highlight groups or text markers
				covered = { hl = "CoverageCovered", text = "▎" },
				uncovered = { hl = "CoverageUncovered", text = "▎" },
			},
			summary = {
				-- customize the summary pop-up
				min_coverage = 0.0, -- minimum coverage threshold (used for highlighting)
			},
			lang = {
				-- customize language specific settings
			},
		})
	end,
}
