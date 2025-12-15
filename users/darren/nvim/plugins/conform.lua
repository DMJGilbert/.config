require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		json = { "prettierd", "prettier", stop_after_first = true },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		go = { "gofmt" },
		dart = { "dart_format" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		nix = { "alejandra" },
		swift = { "swiftformat" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
