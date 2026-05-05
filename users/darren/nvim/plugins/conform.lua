require("conform").setup({
	formatters_by_ft = {
		-- treefmt handles these; falls back to lsp_format if no treefmt config found
		lua = { "treefmt" },
		nix = { "treefmt" },
		rust = { "treefmt" },
		json = { "treefmt" },
		javascript = { "treefmt" },
		javascriptreact = { "treefmt" },
		typescript = { "treefmt" },
		typescriptreact = { "treefmt" },
		css = { "treefmt" },
		html = { "treefmt" },
		-- Not covered by treefmt config; keep individual formatters
		go = { "gofmt" },
		dart = { "dart_format" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		sh = { "shfmt" },
		swift = { "swiftformat" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
