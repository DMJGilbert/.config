return {
	{
		"kylechui/nvim-surround",
		event = "BufReadPre",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "BufReadPre",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
}
