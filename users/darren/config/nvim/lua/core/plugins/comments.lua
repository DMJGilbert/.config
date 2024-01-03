return {
	{
		"tpope/vim-commentary",
		event = "BufReadPre",
	},
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "BufReadPre",
		config = {
			snippet_engine = "vsnip",
		},
		keys = {
			{
				"<leader>df",
				function()
					require("neogen").generate({ type = "func" })
				end,
				desc = "Function Annotation",
			},
			{
				"<leader>dF",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "File Annotation",
			},
			{
				"<leader>qt",
				function()
					require("neogen").generate({ type = "type" })
				end,
				desc = "Type Annotation",
			},
		},
	},
}
