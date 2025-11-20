-- Migrated to vim.lsp.config (Neovim 0.11+)
-- Enable inlay hints globally
vim.lsp.inlay_hint.enable(true)

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

-- Global on_attach callback using LspAttach autocmd (recommended pattern)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			client.server_capabilities.document_formatting = true

			-- Enable inlay hints for this buffer if supported
			if client.supports_method("textDocument/inlayHint") then
				-- Schedule to ensure LSP is fully ready
				vim.schedule(function()
					vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
				end)
			end
		end
		-- LSP keymaps
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>z", vim.lsp.buf.code_action, opts)
	end,
})

-- Ensure inlay hints refresh when entering buffers
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
	callback = function(args)
		if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})

-- Set default root marker for all clients
vim.lsp.config("*", {
	root_markers = { ".git" },
})

-- Lua Language Server
vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
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
}

-- Rust Analyzer
vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json" },
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				disabled = { "inactive-code" },
			},
			check = {
				command = "clippy",
			},
			cargo = {
				loadOutDirsFromCheck = true,
				allFeatures = true,
				buildScripts = {
					enable = true,
				},
			},
			procMacro = {
				enable = true,
			},
			inlayHints = {
				bindingModeHints = {
					enable = false,
				},
				chainingHints = {
					enable = true,
				},
				closingBraceHints = {
					enable = true,
					minLines = 25,
				},
				lifetimeElisionHints = {
					enable = "skip_trivial",
					useParameterNames = true,
				},
				maxLength = 25,
				parameterHints = {
					enable = true,
				},
				renderColons = true,
				typeHints = {
					enable = true,
					hideClosureInitialization = false,
					hideNamedConstructor = false,
				},
			},
		},
	},
}

-- Biome
vim.lsp.config.biome = {
	cmd = { "biome", "lsp-proxy" },
	filetypes = { "json", "javascript", "javascriptreact", "typescript", "typescriptreact", "typescript.tsx" },
	root_markers = { "biome.json", "biome.jsonc" },
	capabilities = capabilities,
}

-- TypeScript Language Server
vim.lsp.config.ts_ls = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	capabilities = capabilities,
}

-- CSS Language Server
vim.lsp.config.cssls = {
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
	root_markers = { "package.json", ".git" },
	capabilities = capabilities,
}

-- HTML Language Server
vim.lsp.config.html = {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	root_markers = { "package.json", ".git" },
	capabilities = capabilities,
}

-- Dart Language Server
vim.lsp.config.dartls = {
	cmd = { "dart", "language-server", "--protocol=lsp" },
	filetypes = { "dart" },
	root_markers = { "pubspec.yaml", ".git" },
	capabilities = capabilities,
}

-- Go Language Server
vim.lsp.config.gopls = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	capabilities = capabilities,
}

-- Bash Language Server
vim.lsp.config.bashls = {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

-- Clangd (C/C++)
vim.lsp.config.clangd = {
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	},
	capabilities = capabilities,
}

-- Tailwind CSS
vim.lsp.config.tailwindcss = {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
		"postcss.config.js",
		"postcss.config.cjs",
		"postcss.config.mjs",
		"postcss.config.ts",
	},
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
}

-- Nix Language Server
vim.lsp.config.nil_ls = {
	cmd = { "nil" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", "default.nix", "shell.nix", ".git" },
	capabilities = capabilities,
}

-- SourceKit (Swift)
vim.lsp.config.sourcekit = {
	cmd = {
		"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
	},
	filetypes = { "swift", "objective-c", "objective-cpp" },
	root_markers = { "buildServer.json", "Package.swift", "Project.swift", ".git" },
	capabilities = capabilities,
}

-- Enable all configured LSP servers
vim.lsp.enable({
	"lua_ls",
	"rust_analyzer",
	"biome",
	"ts_ls",
	"cssls",
	"html",
	"dartls",
	"gopls",
	"bashls",
	"clangd",
	"tailwindcss",
	"nil_ls",
	"sourcekit",
})

-- Configure diagnostic display
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = true,
	signs = false,
	underline = true,
	update_on_insert = true,
})
