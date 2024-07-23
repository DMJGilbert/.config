return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	opts = {
		close_if_last_window = true,
		enable_git_status = false,
		enable_diagnostics = false,
	},
	keys = {
		{
			"<leader>n",
			"<cmd>Neotree focus<cr>",
			desc = "Open file browser",
		},
		{
			"<leader>N",
			"<cmd>Neotree toggle<cr>",
			desc = "Open file browser",
		},
	},
}
