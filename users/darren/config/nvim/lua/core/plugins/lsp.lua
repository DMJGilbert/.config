return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		-- { "gs", "<cmd>lua vim.lsp.buf.declaration()<cr>" },
		{ "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>" },
		-- { "gf", "<cmd>lua vim.diagnostic.open_float()<cr>" },
		{ "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>" },
		{ "<leader>z", "<cmd>lua vim.lsp.buf.code_action()<cr>" },
		-- { "<leader>a", "<cmd>lua vim.diagnostic.goto_next()<cr>" },
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup()
		local nvim_lsp = require("lspconfig")

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities.textDocument.completion.completionItem.resolveSupport = {
			properties = {
				"documentation",
				"detail",
				"additionalTextEdits",
			},
		}
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFolding = true,
		}

		nvim_lsp.lua_ls.setup({
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
			settings = {
				Lua = {
					runtime = {
						-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
						path = vim.split(package.path, ";"),
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- Make the server aware of Neovim runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
						},
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		nvim_lsp.rust_analyzer.setup({
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
			settings = {
				["rust-analyzer"] = {
					diagnostics = {
						disabled = { "inactive-code" },
					},
					imports = {
						granularity = {
							group = "module",
						},
						prefix = "self",
					},
					check = {
						command = "clippy",
					},
					cargo = {
						allFeatures = true,
						buildScripts = {
							enable = true,
						},
					},
					procMacro = {
						enable = true,
					},
				},
			},
		})

		nvim_lsp.biome.setup({
			filetypes = { "json", "javascript", "javascriptreact", "typescript", "typescriptreact", "typescript.tsx" },
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})
		nvim_lsp.tsserver.setup({
			filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})
		-- nvim_lsp.eslint.setup({
		-- 	filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
		-- 	capabilities = capabilities,
		-- 	on_attach = function(client)
		-- 		client.server_capabilities.document_formatting = true
		-- 	end,
		-- })

		nvim_lsp.gopls.setup({
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})

		nvim_lsp.bashls.setup({
			filetypes = { "sh", "bash" },
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})

		nvim_lsp.clangd.setup({
			filetypes = { "c", "cpp", "h", "hpp" },
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})

		nvim_lsp.tailwindcss.setup({
			capabilities = capabilities,
			settings = {
				tailwindCSS = {
					classAttributes = {
						"class",
						"className",
						"classList",
						"enterActiveClass",
						"exitActiveClass",
						"enterClass",
						"exitToClass",
					},
				},
			},
		})

		nvim_lsp.nil_ls.setup({
			capabilities = capabilities,
			on_attach = function(client)
				client.server_capabilities.document_formatting = true
			end,
		})

		-- nvim_lsp.statix.setup({
		--     capabilities = capabilities,
		-- })

		vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			virtual_text = true,
			signs = false,
			underline = true,
			update_on_insert = true,
		})
	end,
}
