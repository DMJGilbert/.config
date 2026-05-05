require("fidget").setup({
	progress = {
		display = {
			done_ttl = 3, -- keep "done" message for 3s before clearing
			render_limit = 8,
		},
	},
	notification = {
		window = {
			winblend = 0, -- match transparent background
			border = "none",
		},
	},
})
