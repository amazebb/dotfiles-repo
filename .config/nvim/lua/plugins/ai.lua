return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "ravitemer/mcphub.nvim" },
        opts = {
            display = {
                action_palette = {
                    width = 95,
                    height = 10,
                    prompt = "Prompt ", -- Prompt used for interactive LLM calls
                    provider = "fzf_lua", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks".
                    opts = {
                        show_default_actions = true, -- Show the default actions in the action palette?
                        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
                    },
                },
            },
            extensions = {
                mcphub = {
                    callback = "mcphub.extensions.codecompanion",
                    opts = {
                        make_vars = true,
                        make_slash_commands = true,
                        show_result_in_chat = true,
                    },
                },
            },
            strategies = {
                chat = {
                    adapter = "xai",
                },
                inline = {
                    adapter = "xai",
                },
                cmd = {
                    adapter = "xai",
                },
            },
            opts = {
                -- Set debug logging
                log_level = "DEBUG",
            },
            prompt_library = {
                ["commit message"] = {
                    strategy = "chat",
                    description = "Generate a commit message based on the current git diff",
                    opts = {
                        is_slash_cmd = true,
                        short_name = "commit-cached-msg",
                        auto_submit = true,
                    },
                    prompts = {
                        {
                            role = "user",
                            content = function()
                                return string.format(
                                    [[You are an expert at following the Conventional Commit specification.
                                    Please generate a commit message for the below diff in a plain text markdown block and nothing else!:
                                    ```diff
                                    %s
                                    ```]],
                                    vim.fn.system("~/.local/scripts/git-wrapper.sh --no-pager diff --no-ext-diff -U0")
                                )
                            end,
                            opts = {
                                contains_code = true,
                            },
                        },
                    },
                },
            },
            adapters = {
                opts = {
                    show_defaults = false,
                },
                mlx_lm = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        name = "mlx_lm",
                        formatted_name = "MLX LM",
                        env = {
                            url = "http://localhost:8080", -- mlx-lm server endpoint
                        },
                        schema = {
                            model = {
                                default = "mlx-community/Qwen3-4B-4bit", -- define llm model to be used
                                choices = {
                                    "mlx-community/Qwen3-8B-4bit",
                                    "mlx-community/Josiefied-Qwen3-1.7B-abliterated-v1-4bit",
                                },
                            },
                        },
                    })
                end,
                xai = function()
                    return require("codecompanion.adapters").extend("xai", {
                        env = {
                            api_key = "cmd:security find-generic-password -s xai-api-key -w 2>/dev/null",
                        },
                        schema = {
                            ---@type CodeCompanion.Schema
                            model = {
                                order = 1,
                                mapping = "parameters",
                                type = "enum",
                                desc = "ID of the model to use",
                                default = "grok-3-beta",
                                choices = {
                                    "grok-3-beta",
                                    "grok-3-mini-beta",
                                    "grok-3-fast-beta",
                                    "grok-3-min-fast-beta",
                                },
                            },
                        },
                    })
                end,
            },
        },
    },

    -- MCP
    {
        "ravitemer/mcphub.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
        },
        opts = {},
        cmd = "MCPHub", -- lazy load
        build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
        -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
        -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    },
}
