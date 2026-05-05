-- Load friendly-snippets (VSCode format snippets via LuaSnip)
require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").setup({
	keymap = {
		-- No preset — define all keymaps explicitly to mirror the old nvim-cmp layout
		preset = "none",

		-- Trigger / hide
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },

		-- Confirm (select = true mirrors old cmp behaviour)
		["<CR>"] = { "accept", "fallback" },

		-- Navigation
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },

		-- Scroll documentation popup
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },

		-- Tab: jump snippet → select next → fallback (super-tab behaviour)
		["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

		-- Explicit snippet navigation (mirrors old C-j / C-k)
		["<C-j>"] = { "snippet_forward", "fallback" },
		["<C-k>"] = { "snippet_backward", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},

	completion = {
		accept = {
			-- Auto-insert closing bracket/paren after accepting a function completion
			auto_brackets = { enabled = true },
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
		ghost_text = { enabled = true },
		menu = {
			draw = {
				-- Use treesitter to highlight LSP completion items
				treesitter = { "lsp" },
			},
		},
		list = { max_items = 50 },
	},

	sources = {
		-- Default source list for all filetypes; lazydev auto-filters to Lua only
		default = { "lazydev", "lsp", "path", "snippets", "buffer", "crates", "minuet" },

		providers = {
			-- lazydev: full Neovim API type annotations for Lua config files
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
			lsp = {
				min_keyword_length = 1,
				score_offset = 10,
				max_items = 20,
			},
			path = {
				score_offset = 5,
			},
			snippets = {
				min_keyword_length = 2,
				max_items = 10,
				score_offset = 5,
			},
			buffer = {
				min_keyword_length = 3,
				max_items = 5,
				score_offset = -5,
			},
			-- crates.nvim via blink-compat (Rust Cargo.toml completions)
			crates = {
				name = "crates",
				module = "blink.compat.source",
				score_offset = -1,
				opts = {},
			},
			-- Local LLM FIM completions via minuet-ai.nvim + Ollama
			minuet = {
				name = "minuet",
				module = "minuet.blink",
				score_offset = -3,
				async = true,
				min_keyword_length = 0,
			},
		},
	},

	snippets = {
		-- Use LuaSnip as the snippet engine (friendly-snippets loaded above)
		preset = "luasnip",
	},

	signature = {
		-- Inline function signature help while typing arguments
		enabled = true,
	},

	cmdline = {
		sources = { "cmdline" },
	},
})

-- LuaSnip choice node cycling (no equivalent in blink keymap)
local luasnip = require("luasnip")
vim.keymap.set({ "i", "s" }, "<C-l>", function()
	if luasnip.choice_active() then
		luasnip.change_choice(1)
	end
end, { silent = true, desc = "LuaSnip: next choice" })
