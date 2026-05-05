local lint = require("lint")

lint.linters_by_ft = {
	-- JavaScript / TypeScript (React + Node)
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },

	-- Nix
	nix = { "statix" },

	-- Shell
	sh = { "shellcheck" },
	bash = { "shellcheck" },

	-- Swift
	swift = { "swiftlint" },
}

-- Trigger linting on write, read, and leaving insert mode
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		-- Only lint regular file buffers (not terminals, help, etc.)
		if vim.bo.buftype == "" then
			lint.try_lint()
		end
	end,
})
