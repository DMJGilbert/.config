return {
	"mhartington/formatter.nvim",
	event = "BufReadPre",
	config = function()
		local util = require("formatter.util")

		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
					function()
						return {
							exe = "stylua",
							args = {
								"--search-parent-directories",
								"--stdin-filepath",
								util.escape_path(util.get_current_buffer_file_path()),
								"--",
								"-",
							},
							stdin = true,
						}
					end,
				},

				json = { require("formatter.filetypes.json").prettierd },
				javascript = { require("formatter.filetypes.javascript").prettierd },
				javascriptreact = { require("formatter.filetypes.javascriptreact").prettierd },
				typescript = { require("formatter.filetypes.typescript").prettierd },
				typescriptreact = { require("formatter.filetypes.typescriptreact").prettierd },
				go = { require("formatter.filetypes.go").gofmt },
				c = { require("formatter.filetypes.c").clangformat },
				cpp = { require("formatter.filetypes.cpp").clangformat },
				rust = { require("formatter.filetypes.rust").rustfmt },
				sh = { require("formatter.filetypes.sh").shfmt },
				nix = { require("formatter.filetypes.nix").nixfmt },
				["*"] = {
					function()
						return { exe = "sed", args = { "-i", "''", "'s/[	 ]*$//'" } }
					end,
				},
			},
		})
	end,
}
