require("lspsaga").setup({
	lightbulb = {
		enable = true,
		enable_in_insert = false,
		sign = false,
	},
	breadcrumb = {
		enable = false,
	},
})

-- Keymaps
vim.keymap.set("n", "gs", "<cmd>Lspsaga finder<cr>")
vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>")
vim.keymap.set("n", "gf", "<cmd>Lspsaga show_cursor_diagnostics<cr>")
vim.keymap.set("n", "<leader>a", "<cmd>Lspsaga diagnostic_jump_next<cr>")
vim.keymap.set("n", "<leader>A", "<cmd>Lspsaga diagnostic_jump_prev<cr>")
