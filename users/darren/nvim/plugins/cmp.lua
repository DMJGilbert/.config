local cmp = require("cmp")
local luasnip = require("luasnip")

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Helper function to check if there are words before cursor
local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		-- Navigation
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),

		-- Scrolling docs
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),

		-- Trigger completion
		["<C-Space>"] = cmp.mapping.complete(),

		-- Abort
		["<C-e>"] = cmp.mapping.abort(),

		-- Confirm selection
		["<CR>"] = cmp.mapping.confirm({ select = true }),

		-- Super-tab: Tab for completion and snippet navigation
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	-- Source priority: higher priority sources appear first
	-- Group 1 (highest): LSP, signatures, snippets
	-- Group 2: Buffer, path
	-- Group 3: Spelling, other
	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 1000, max_item_count = 20 },
		{ name = "nvim_lsp_signature_help", priority = 900 },
		{ name = "luasnip", priority = 800, max_item_count = 10 },
		{ name = "nvim_lua", priority = 700 },
		{ name = "crates", priority = 700 },
	}, {
		{ name = "treesitter", priority = 500, max_item_count = 10 },
		{
			name = "buffer",
			priority = 400,
			max_item_count = 5,
			option = {
				get_bufnrs = function()
					-- Only use visible buffers for performance
					local bufs = {}
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						bufs[vim.api.nvim_win_get_buf(win)] = true
					end
					return vim.tbl_keys(bufs)
				end,
			},
		},
		{ name = "path", priority = 300 },
	}, {
		{ name = "spell", priority = 100, max_item_count = 5 },
	}),

	completion = {
		completeopt = "menu,menuone,noinsert",
		keyword_length = 1,
	},

	performance = {
		debounce = 60,
		throttle = 30,
		fetching_timeout = 200,
		max_view_entries = 50,
	},

	sorting = {
		priority_weight = 2,
		comparators = {
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.score,
			cmp.config.compare.recently_used,
			cmp.config.compare.locality,
			cmp.config.compare.kind,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},

	experimental = {
		ghost_text = { hl_group = "Comment" },
	},
})

-- Cmdline "/" search completion
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Cmdline "?" search completion
cmp.setup.cmdline("?", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Cmdline ":" command completion
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{
			name = "cmdline",
			option = {
				ignore_cmds = { "Man", "!" },
			},
		},
	}),
})

-- LuaSnip keymaps for jumping within snippets
vim.keymap.set({ "i", "s" }, "<C-j>", function()
	if luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-k>", function()
	if luasnip.jumpable(-1) then
		luasnip.jump(-1)
	end
end, { silent = true })

-- Choice node cycling
vim.keymap.set({ "i", "s" }, "<C-l>", function()
	if luasnip.choice_active() then
		luasnip.change_choice(1)
	end
end, { silent = true })
