require("persistence").setup({
	dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
	options = { "buffers", "curdir", "tabpages", "winsize" },
	pre_save = function()
		vim.cmd("Neotree close")
		-- Close any lazy.nvim floating windows before saving session
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buftype = vim.bo[buf].buftype
			local filetype = vim.bo[buf].filetype
			if filetype == "lazy" or buftype == "nofile" then
				pcall(vim.api.nvim_win_close, win, true)
			end
		end
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
