local wk = require("which-key")

wk.setup({
	delay = 400,
	icons = {
		mappings = false, -- no icons next to every binding
		separator = "→",
	},
	win = {
		border = "none",
	},
})

wk.add({
	-- Leader group labels
	{ "<leader>g", group = "git" },
	{ "<leader>r", group = "reload / rename" },
	{ "<leader>v", group = "vim" },
	{ "<leader>n", group = "npm" },

	-- Buffer / window
	{ "<leader>q", desc = "Close buffer" },
	{ "<leader>Q", desc = "Close all buffers" },
	{ "<leader>b", desc = "Find buffer" },

	-- File finding
	{ "<leader>o", desc = "Find files" },
	{ "<leader>O", desc = "Find all files (no ignore)" },
	{ "<leader>e", desc = "Search workspace (grep)" },

	-- LSP / code
	{ "<leader>i", desc = "Document symbols" },
	{ "<leader>x", desc = "Diagnostics list" },
	{ "<leader>z", desc = "Code action" },
	{ "<leader>a", desc = "Next diagnostic" },
	{ "<leader>A", desc = "Prev diagnostic" },
	{ "<leader>rn", desc = "Rename symbol" },

	-- Tests
	{ "<leader>T", group = "test" },
	{ "<leader>Tr", desc = "Run nearest test" },
	{ "<leader>Tf", desc = "Run test file" },
	{ "<leader>Tl", desc = "Run last test" },
	{ "<leader>Ts", desc = "Toggle test summary" },
	{ "<leader>To", desc = "Open test output" },
	{ "<leader>TO", desc = "Toggle output panel" },
	{ "<leader>Tx", desc = "Stop test run" },

	-- Tools
	{ "<leader>t", desc = "TODO list" },
	{ "<leader>u", desc = "Undo tree" },
	{ "<leader>c", desc = "Load coverage" },
	{ "<leader>gg", desc = "LazyGit" },
	{ "<leader><leader>", desc = "Resume telescope" },
	{ "<leader><CR>", desc = "Clear messages / session" },

	-- Clipboard
	{ "<leader>p", desc = "Paste from system clipboard" },
	{ "<leader>y", mode = "v", desc = "Copy to system clipboard" },
	{ "<leader>Y", mode = "v", desc = "Copy line to system clipboard" },

	-- Go-to navigation (g prefix)
	{ "g", group = "goto" },
	{ "gd", desc = "Go to definition" },
	{ "gi", desc = "Go to implementation" },
	{ "gr", desc = "Find references" },
	{ "gs", desc = "LSP finder" },
	{ "gf", desc = "Cursor diagnostics" },

	-- Flash motions
	{ "s", desc = "Flash: jump" },
	{ "S", desc = "Flash: treesitter jump" },
})
