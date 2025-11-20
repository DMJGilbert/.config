require("gitsigns").setup({
	signcolumn = false,
	numhl = true,
	sign_priority = 0,
})
local colors = require("catppuccin.palettes").get_palette()
vim.api.nvim_set_hl(0, "GitSignsAddNr", { bg = colors.teal, fg = colors.mantle })
vim.api.nvim_set_hl(0, "GitSignsChangeNr", { bg = colors.peach, fg = colors.mantle })
vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { bg = colors.red, fg = colors.mantle })
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Git blame current line" })
