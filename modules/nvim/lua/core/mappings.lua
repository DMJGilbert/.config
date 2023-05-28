local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("n", "<ESC>", "<nop>")
map("n", "<leader>vr", ":luafile $MYVIMRC<cr>")
map("n", "<leader>nb", ":!npm run build<cr>")

-- Copy characters
map("v", "<leader>y", '"+y', { noremap = true })
-- Copy lines
map("v", "<leader>Y", '"+Y', { noremap = true })
-- Paste
map("n", "<leader>p", '"+p', { noremap = true })

map("i", "<C-BS>", "<C-W>", { noremap = true })
-- Unbind default bindings for arrow keys
-- map("n", "<up>", "<nop>")
-- map("n", "<up>", "<nop>")
-- map("n", "<down>", "<nop>")
-- map("n", "<left>", "<nop>")
-- map("n", "<right>", "<nop>")
-- map("v", "<down>", "<nop>")
-- map("v", "<left>", "<nop>")
-- map("v", "<right>", "<nop>")
-- map("i", "<up>", "<nop>")
-- map("i", "<down>", "<nop>")
-- map("i", "<left>", "<nop>")
-- map("i", "<right>", "<nop>")

-- vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = true })
-- vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", { noremap = true })
-- vim.api.nvim_set_keymap("n", "{", "{zz", { noremap = true })
-- vim.api.nvim_set_keymap("n", "}", "}zz", { noremap = true })

-- Stay in indent mode when tabbing in virtual mode
map("v", "<", "<gv", {})
map("v", ">", ">gv", {})
map("v", ">", ">gv", {})

-- Map leader q, to close current buffer
map("n", "<leader>q", "<cmd>bdelete<cr>")
-- Map leader Q, to close all buffers
map("n", "<leader>Q", "<cmd>SessionDelete<cr><cmd>bufdo bd<cr><cmd>Alpha<cr>")

-- Map escape from terminal input to Normal mode
map("t", "<esc>", [[<C-\><C-n>]])

-- Manual completion
map("i", "<C-Space>", "<C-x><C-o>")

-- Disable highlights
map("n", "<leader><CR>", ":noh<CR>")

-- Reload file
map("n", "<leader>r", ":e!<CR>")
