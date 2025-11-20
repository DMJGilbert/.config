return {
	{
		"tpope/vim-commentary",
		event = "BufReadPre",
		config = function()
			-- require("vim-commentary").setup()
			vim.cmd("autocmd FileType dart setlocal commentstring=//\\ %s")
		end,
	},
}
