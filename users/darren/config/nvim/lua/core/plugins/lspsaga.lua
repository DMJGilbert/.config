return {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    keys = {
		{ "gs", "<cmd>Lspsaga lsp_finder<cr>" },
		{ "gd", "<cmd>Lspsaga goto_definition<cr>" },
		-- { "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>" },
		{ "gf", "<cmd>Lspsaga show_cursor_diagnostics<cr>" },
		-- { "<leader>z", "<cmd>Lspsaga diagnostic_jump_prev<cr>" },
		{ "<leader>a", "<cmd>Lspsaga diagnostic_jump_next<cr>" },
    },
    config = function()
      require("lspsaga").setup({
          lightbulb = {
              enable= true,
              enable_in_insert = false,
              sign = false,
          }
      })
    end,
}
