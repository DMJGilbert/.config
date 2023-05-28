return {
	"declancm/cinnamon.nvim",
	config = function()
		require("cinnamon").setup({
			default_keymaps = true,
			extra_keymaps = true,
			extended_keymaps = true,
			override_keymaps = false,
			default_delay = 1,
			max_length = 50,
			scroll_limit = -1,
			horizontal_scroll = true,
			always_scroll = true,
			center = true,
		})
	end,
}
