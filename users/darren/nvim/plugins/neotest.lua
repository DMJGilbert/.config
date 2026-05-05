local neotest = require("neotest")

neotest.setup({
	adapters = {
		-- Rust: uses cargo nextest (faster than cargo test, install via Nix)
		require("neotest-rust")({
			args = { "--no-capture" }, -- show println! output in results
		}),

		-- Jest (Node / React with jest)
		require("neotest-jest")({
			jestCommand = "npx jest",
			jestConfigFile = function(file)
				-- Walk up to find the nearest jest config
				local path = require("plenary.path"):new(file)
				for _, name in ipairs({ "jest.config.ts", "jest.config.js", "jest.config.mjs" }) do
					local cfg = path:parent():joinpath(name)
					if cfg:exists() then
						return cfg:absolute()
					end
				end
			end,
			env = { CI = "true" },
			cwd = function()
				return vim.fn.getcwd()
			end,
		}),

		-- Vitest (Vite-based projects)
		require("neotest-vitest"),
	},

	-- Show diagnostic signs in the gutter
	diagnostic = { enabled = true },

	-- Floating output window
	output = { open_on_run = false },

	-- Summary panel appearance
	summary = {
		animated = false,
	},
})

-- Keymaps (<leader>T namespace)
vim.keymap.set("n", "<leader>Tr", function()
	neotest.run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>Tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })

vim.keymap.set("n", "<leader>Tl", function()
	neotest.run.run_last()
end, { desc = "Run last test" })

vim.keymap.set("n", "<leader>Ts", function()
	neotest.summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>To", function()
	neotest.output.open({ enter = true })
end, { desc = "Open test output" })

vim.keymap.set("n", "<leader>TO", function()
	neotest.output_panel.toggle()
end, { desc = "Toggle output panel" })

vim.keymap.set("n", "<leader>Tx", function()
	neotest.run.stop()
end, { desc = "Stop test run" })
