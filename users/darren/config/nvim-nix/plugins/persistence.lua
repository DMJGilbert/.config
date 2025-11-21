require("persistence").setup({
	dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
	options = { "buffers", "curdir", "tabpages", "winsize" },
	pre_save = function()
		vim.cmd("Neotree close")
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
	once = true,
	nested = true,
	callback = function()
		if vim.fn.argc(-1) == 0 then
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
