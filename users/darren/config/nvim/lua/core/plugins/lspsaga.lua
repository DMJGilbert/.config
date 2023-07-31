return {
	"glepnir/lspsaga.nvim",
	event = "LspAttach",
	keys = {
		{ "gs", "<cmd>Lspsaga finder<cr>" },
		{ "gd", "<cmd>Lspsaga goto_definition<cr>" },
		-- { "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>" },
		{ "gf", "<cmd>Lspsaga show_cursor_diagnostics<cr>" },
		-- { "<leader>z", "<cmd>Lspsaga diagnostic_jump_prev<cr>" },
		{ "<leader>a", "<cmd>Lspsaga diagnostic_jump_next<cr>" },
		{ "<leader>A", "<cmd>Lspsaga diagnostic_jump_prev<cr>" },
	},
	config = function()
		require("lspsaga").setup({
			lightbulb = {
				enable = true,
				enable_in_insert = false,
				sign = false,
			},
			breadcrumb = {
				enable = false,
			},
		})
	end,
}
