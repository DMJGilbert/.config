return {
	"mbbill/undotree",
	lazy = true,
	cmd = "UndotreeToggle",
	keys = {
		{
			"<leader>u",
			function()
				vim.cmd.UndotreeToggle()
			end,
			desc = "Open UndoTree",
		},
	},
}
