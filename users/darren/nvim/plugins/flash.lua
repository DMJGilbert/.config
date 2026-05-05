require("flash").setup({
	-- Default config is sensible; override only what's needed
	modes = {
		-- / and ? search: press <C-s> to toggle flash labels
		search = { enabled = true },
	},
})

-- s: jump to any visible location (replaces the rarely-used 'substitute' alias for cl)
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash: jump" })

-- S: jump using treesitter node selection
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash: treesitter jump" })

-- r (operator-pending): act on a remote location without moving the cursor
vim.keymap.set("o", "r", function()
	require("flash").remote()
end, { desc = "Flash: remote action" })

-- R (operator-pending / visual): treesitter search across file
vim.keymap.set({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Flash: treesitter search" })

-- <C-s> in command mode: toggle flash labels inside / searches
vim.keymap.set("c", "<C-s>", function()
	require("flash").toggle()
end, { desc = "Flash: toggle in search" })
