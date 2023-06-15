return {
	"phaazon/hop.nvim",
	keys = {
		{ "f", mode = { "n", "x", "o" }, desc = "hop improved f" },
		{ "F", mode = { "n", "x", "o" }, desc = "hop improved F" },
		{ "t", mode = { "n", "x", "o" }, desc = "hop improved t" },
		{ "T", mode = { "n", "x", "o" }, desc = "hop improved T" },
	},
	config = function()
		local mode = { "n", "x", "o" }
		local hop = require("hop")
		local directions = require("hop.hint").HintDirection
		local echo = vim.api.nvim_echo
		local noop = function() end
		vim.keymap.set(mode, "f", function()
			--disable nvim_echo temporarily
			vim.api.nvim_echo = noop
			hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
		end, { remap = true })
		vim.keymap.set(mode, "F", function()
			vim.api.nvim_echo = noop
			hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
		end, { remap = true })
		vim.keymap.set(mode, "t", function()
			vim.api.nvim_echo = noop
			hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
		end, { remap = true })
		vim.keymap.set(mode, "T", function()
			vim.api.nvim_echo = noop
			hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
		end, { remap = true })

		require("hop").setup()

		if vim.api.nvim_echo == noop then
			vim.api.nvim_echo = echo
		end
	end,
}
