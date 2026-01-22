---@class AI
local M = {}

M.ai = {
    provider = "xai",
    temperature = 0.2,
    max_tokens = 1000,
    xai = {
        url = {
            chat = "https://api.x.ai/v1/chat/completions",
            billing = "https://management-api.x.ai/v1/billing/teams/TEAMID/prepaid/balance"
        },
        models = { "grok-4-1-fast-reasoning", "grok-4-1-fast-non-reasoning", "grok-code-fast-1", "grok-4-fast-reasoning", "grok-4-fast-non-reasoning" },
        selected_model = "grok-4-fast-non-reasoning",
    },
    system =
    {
        commit_msg = [[
You are an expert at writing Conventional Commits.
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
}

---Get the api-key given API type
---@param opt string
---@return string
local function keyname(opt)
    local key_name = M.ai.provider
    if opt == "chat" then
        key_name = key_name .. "-api-key"
    elseif opt == "manage" then
        key_name = key_name .. "-manage-api-key"
    elseif opt == "team" then
        key_name = key_name .. "-team-id"
    end
    return (assert(require("functions").get_password(key_name), "keyname: No key found for " .. key_name))
end

local function get_billing()
    vim.system({ "curl", (M.ai[M.ai.provider].url.billing:gsub("TEAMID", keyname("team"))),
        "-H", "Authorization: Bearer " .. keyname("manage"),
    }, { text = true }, vim.schedule_wrap(function(res)
        if res.code ~= 0 then
            vim.notify(M.ai.provider .. " API call failed", vim.log.levels.ERROR)
            return
        end
        local fun = require("functions")
        fun.floating_window(vim.split(res.stdout, "\n", { plain = true }),
            {
                fun = function(_, buf)
                    fun.pretty_json(buf)
                end
            })
    end))
end

local function generate_conventional_commit()
    vim.system(
        { "zsh", "-c", "dotfiles d -b" },
        { text = true },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                vim.notify("diff command failed", vim.log.levels.ERROR)
                return
            end

            local diff = result.stdout
            local payload = vim.json.encode({
                model = M.ai[M.ai.provider].selected_model,
                messages = {
                    {
                        role = "system",
                        content = M.ai.system.commit_msg,
                    },
                    { role = "user", content = "Generate a conventional commit message for this diff:\n\n" .. diff }
                },
                temperature = M.ai.temperature,
                max_tokens = M.ai.max_tokens
            })

            vim.system({
                "curl", M.ai[M.ai.provider].url.chat,
                "-H", "Content-Type: application/json",
                "-H", "Authorization: Bearer " .. keyname("chat"),
                "-d", payload
            }, { text = true }, vim.schedule_wrap(function(res)
                if res.code ~= 0 then
                    vim.notify(M.ai.provider .. " API call failed", vim.log.levels.ERROR)
                    return
                end
                local resp = vim.json.decode(res.stdout)
                local commit_msg = resp.choices[1].message.content

                vim.fn.setreg('+', commit_msg)

                require("functions").commit_msg_popup()
            end))
        end)
    )
end

vim.keymap.set("n", "<leader>cc", generate_conventional_commit, { desc = "Generate conventional commit via AI" })
vim.keymap.set("n", "<leader>ab", get_billing, { desc = "Get AI provider billing information" })
