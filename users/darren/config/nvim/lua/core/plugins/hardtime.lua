return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {
		disabled_filetypes = { "NvimTree", "lazy" },
		disabled_keys = {
			["<Up>"] = {},
			["<Down>"] = {},
			["<Left>"] = {},
			["<Right>"] = {},
		},
	},
}
