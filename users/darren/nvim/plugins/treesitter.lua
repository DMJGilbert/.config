-- nvim-treesitter setup
-- Parsers are pre-installed via Nix withAllGrammars
-- Since nvim-treesitter main branch rewrite, we need to:
-- 1. Call setup() to initialize the plugin
-- 2. Enable highlighting via vim.treesitter.start() per buffer

-- Initialize nvim-treesitter (required for query files to load)
require("nvim-treesitter").setup({})

-- Enable treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
	pattern = "*",
	callback = function(event)
		-- Skip special buffer types
		local bt = vim.bo[event.buf].buftype
		if bt == "nofile" or bt == "prompt" or bt == "help" then
			return
		end

		-- Get the filetype and check if a parser exists
		local ft = vim.bo[event.buf].filetype
		local lang = vim.treesitter.language.get_lang(ft) or ft

		-- Check if parser is available before trying to start
		local ok = pcall(vim.treesitter.language.inspect, lang)
		if not ok then
			return
		end

		-- Enable treesitter highlighting for this buffer
		pcall(vim.treesitter.start, event.buf, lang)
	end,
})

-- nvim-ts-autotag now has its own setup (deprecated from treesitter.configs)
require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
})

-- vim-matchup is configured via g:matchup_* variables, not treesitter
vim.g.matchup_matchparen_offscreen = { method = "popup" }
