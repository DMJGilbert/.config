local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = {
		["<down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i", "c" }),
		["<up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i", "c" }),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { "i", "c" }),
	},
	completion = {
		completeopt = "menu,menuone,noinsert",
		keyword_length = 2,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
		{
			name = "buffer",
			option = {
				get_bufnrs = function()
					local bufs = {}
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						bufs[vim.api.nvim_win_get_buf(win)] = true
					end
					return vim.tbl_keys(bufs)
				end,
			},
		},
		{ name = "look", keyword_length = 3, option = { convert_case = true, loud = true } },
		{ name = "calc" },
		{ name = "path" },
		{ name = "crates" },
		{ name = "spell" },
	},
	experimental = {
		ghost_text = true,
		native_menu = false,
	},
	sorting = {
		priority_weight = 2,
		comparators = {
			cmp.config.compare.score,
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.order,
		},
	},
})

cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
		{
			name = "cmdline",
			option = {
				ignore_cmds = { "Man", "!" },
			},
		},
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
		{
			name = "cmdline",
			option = {
				ignore_cmds = { "Man", "!" },
			},
		},
	}),
})

local function vsnip_map(key, cmd)
	local options = {
		expr = true,
		silent = true,
	}
	vim.api.nvim_set_keymap("i", key, cmd, options)
	vim.api.nvim_set_keymap("s", key, cmd, options)
end
vsnip_map("<c-j>", [[vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<c-j>']])
vsnip_map("<tab>", [[vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<Tab>']])
vsnip_map("<S-Tab>", [[vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>']])
