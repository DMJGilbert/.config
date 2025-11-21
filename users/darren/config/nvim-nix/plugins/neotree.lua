require("neo-tree").setup({
	close_if_last_window = true,
	enable_git_status = false,
	enable_diagnostics = false,
})
vim.keymap.set("n", "<leader>n", "<cmd>Neotree focus<cr>", { desc = "Open file browser" })
vim.keymap.set("n", "<leader>N", "<cmd>Neotree toggle<cr>", { desc = "Toggle file browser" })
