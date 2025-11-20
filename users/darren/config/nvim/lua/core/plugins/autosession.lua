return {
	"folke/persistence.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
		options = { "buffers", "curdir", "tabpages", "winsize" },
		pre_save = function()
			-- Close Neotree before saving session
			vim.cmd("Neotree close")
		end,
	},
	config = function(_, opts)
		require("persistence").setup(opts)

		-- Auto-restore session on startup
		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
			once = true,
			nested = true,
			callback = function()
				-- Only load the session if nvim was started with no args
				if vim.fn.argc(-1) == 0 then
					-- Don't restore in certain directories
					local cwd = vim.fn.getcwd()
					local suppress_dirs = {
						vim.fn.expand("~") .. "$",
						vim.fn.expand("~/Downloads"),
						vim.fn.expand("~/Developer") .. "$",
					}

					local should_suppress = false
					for _, dir in ipairs(suppress_dirs) do
						if cwd:match(dir) then
							should_suppress = true
							break
						end
					end

					if not should_suppress then
						vim.schedule(function()
							require("persistence").load()
						end)
					end
				end
			end,
		})
	end,
}
