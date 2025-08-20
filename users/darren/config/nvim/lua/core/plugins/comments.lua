return {
	{
		"David-Kunz/gen.nvim",
		opts = {
			model = "codellama:7b", -- The default model to use.
			debug = false,
			quit_map = "q", -- set keymap to close the response window
			retry_map = "<c-r>", -- set keymap to re-send the current prompt
			accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
			host = "127.0.0.1", -- The host running the Ollama service.
			port = "11434", -- The port on which the Ollama service is listening.
			display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split" or "vertical-split".
			show_prompt = false, -- Shows the prompt submitted to Ollama. Can be true (3 lines) or "full".
			show_model = false, -- Displays which model you are using at the beginning of your chat session.
			no_auto_close = false, -- Never closes the window automatically.
			file = false, -- Write the payload to a temporary file to keep the command short.
			hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
			init = function(options) end,
			-- Function to initialize Ollama
			command = function(options)
				local body = { model = options.model, stream = true }
				return "curl --silent --no-buffer -X POST http://"
					.. options.host
					.. ":"
					.. options.port
					.. "/api/chat -d $body"
			end,
			result_filetype = "markdown", -- Configure filetype of the result buffer
		},
	},
	{
		"tpope/vim-commentary",
		event = "BufReadPre",
		config = function()
			-- require("vim-commentary").setup()
			vim.cmd("autocmd FileType dart setlocal commentstring=//\\ %s")
		end,
	},
}
