local function get_api_key()
    local result = vim.system(
        { 'security', 'find-generic-password', '-s', 'xai-api-key', '-w' },
        { text = true, timeout = 5000 }
    ):wait()

    if result.code ~= 0 then
        local msg = 'Failed to read xai-api-key from keychain (code ' .. result.code .. ')'
        vim.notify(msg, vim.log.levels.ERROR)
        error(msg)
    end
    return result.stdout:gsub('%s+$', '')
end

local function generate_conventional_commit()
    vim.system(
        { "git-wrapper", "d", "-b" },
        { text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                vim.notify("diff command failed", vim.log.levels.ERROR)
                return
            end

            local diff = result.stdout
            local payload = vim.json.encode({
                -- model = "grok-code-fast-1",
                model = "grok-4-1-fast-non-reasoning",
                messages = {
                    {
                        role = "system",
                        content = [[You are an expert at writing Conventional Commits.
Return ONLY the commit message without any markdown quotes around the commit.
Format must be valid Conventional Commits:
<type>(<scope>): <short description>

<body>

<footer>

Types: feat, fix, refactor, perf, chore, docs, test, build, ci, revert
Scope is optional but preferred when clear.
Short description is a one line summary.
Body is a paragraph of dot points, where each change is a dot point
Footer is optional]]
                    },
                    { role = "user", content = "Generate a conventional commit message for this diff:\n\n" .. diff }
                },
                temperature = 0.2,
                max_tokens = 1000
            })

            vim.system({
                "curl", "https://api.x.ai/v1/chat/completions",
                "-H", "Content-Type: application/json",
                "-H", "Authorization: Bearer " .. get_api_key(),
                "-d", payload
            }, { text = true }, vim.schedule_wrap(function(curl_res)
                if curl_res.code ~= 0 then
                    vim.notify("xAI API call failed", vim.log.levels.ERROR)
                    return
                end
                local resp = vim.json.decode(curl_res.stdout)
                local commit_msg = resp.choices[1].message.content

                -- put commit message into clipboard
                vim.fn.setreg('+', commit_msg)
                -- vim.notify("Conventional commit ready:\n\n" .. commit_msg, vim.log.levels.INFO)
                local buf_opts = { modifiable = true }
                local float_opts = { title = "Commit Message" }
                require("functions").create_popup(vim.split(commit_msg, "\n"), buf_opts, float_opts)
            end))
        end)
    )
end

-- Example binding
vim.keymap.set("n", "<leader>cc", generate_conventional_commit, { desc = "Generate conventional commit via xAI" })
