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
	{
		"echasnovski/mini.indentscope",
		config = function()
			local indentScope = require("mini.indentscope")
			indentScope.setup({
				draw = {
					delay = 0,
					animation = indentScope.gen_animation.none(),
				},
			})
		end,
	},
}
