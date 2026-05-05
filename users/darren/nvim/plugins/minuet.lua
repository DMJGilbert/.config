require("minuet").setup({
	notify = "error",
	-- Use the OpenAI FIM-compatible endpoint; Ollama exposes this at /v1/completions
	-- and injects the correct qwen2.5-coder FIM tokens automatically.
	provider = "openai_fim_compatible",

	-- Number of completions to request; keep at 1 for local models to reduce latency
	n_completions = 1,

	-- Tokens of surrounding context sent to the model.
	-- 512 is a good balance for a local 7B model — large enough for useful completions,
	-- small enough to keep prompt-eval fast.
	context_window = 512,

	-- Wait 1000ms of typing inactivity before firing a request.
	-- Higher than cloud defaults because local inference has non-trivial startup cost.
	throttle = 1000,
	debounce = 500,

	provider_options = {
		openai_fim_compatible = {
			-- Ollama does not require an API key; TERM is a placeholder that prevents
			-- minuet from raising a missing-key error.
			api_key = "TERM",
			name = "Ollama",
			end_point = "http://localhost:11434/v1/completions",
			model = "qwen2.5-coder:7b-base",
			stream = false,
			optional = {
				max_tokens = 56,
				top_p = 0.9,
				temperature = 0.2,
			},
		},
	},
})
