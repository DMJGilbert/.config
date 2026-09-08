require("lspsaga").setup({
	lightbulb = {
		enable = true,
		enable_in_insert = false,
		sign = false,
	},
	-- The option is symbol_in_winbar, not breadcrumb. The wrong key was merged
	-- as an ignored extra, so lspsaga's winbar stayed ON the whole time.
	symbol_in_winbar = {
		enable = false,
	},
})

-- Keymaps
vim.keymap.set("n", "gs", "<cmd>Lspsaga finder<cr>")
vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>")
vim.keymap.set("n", "<leader>a", "<cmd>Lspsaga diagnostic_jump_next<cr>")
vim.keymap.set("n", "<leader>A", "<cmd>Lspsaga diagnostic_jump_prev<cr>")
