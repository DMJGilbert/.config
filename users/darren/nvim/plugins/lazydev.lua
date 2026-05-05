require("lazydev").setup({
	library = {
		-- Load luvit types when vim.uv is referenced
		{ path = "luvit-meta/library", words = { "vim%.uv" } },
	},
})
