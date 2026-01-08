---@class Profiler
---@field public profile function Profile a synchronous function
---@field public async function Profile an async function

local M = {}

---Profile a synchronous function
---
---Examples:
---```lua
--- local P = require("profile")
--- -- 1. Profile a synchronous function every time it is run
--- local compute_heavy = P.profile("my_fun", my_fun)
--- compute_heavy()
---
---
--- -- 2. Profile a user command, can be inserted into nvim_create_user_command
--- vim.api.nvim_create_user_command("HeavyCmd", P.profile("HeavyCmd", function()
---   vim.system({ "sleep", "0.1" }):wait()
---   print("Command done")
--- end), {})
--- ```
---
---@param name string Name of the function, does not have to be same as fn
---@param fn function The function to profile
---@return function fun Return profiled function
function M.profile(name, fn)
    return function(...)
        local start = vim.uv.hrtime()
        local ok, result = pcall(fn, ...)
        local elapsed = (vim.uv.hrtime() - start) / 1e6

        vim.print(("[PROFILE-SYNC] %s: %.3f ms"):format(name, elapsed))

        if not ok then
            error(result)
        end
        return result
    end
end

---Profile an async function
---
---Examples: Profile an async callback (timer, LSP, uv)
---```lua
--- local P = require("profile")
--- local timer = vim.uv.new_timer()
--- timer:start(1000, 0, P.async("timer_callback", function()
---   vim.loop.sleep(50)
---   print("Timer fired!")
--- end))
--- ```
---
---@param name string Name of the function, does not have to be same as fn
---@param fn function The function to profile
---@return function fun Returned profiled function
function M.async(name, fn)
    return function(...)
        local start = vim.uv.hrtime()
        local ok, result = pcall(fn, ...)
        local elapsed = (vim.uv.hrtime() - start) / 1e6

        vim.schedule(function()
            vim.print(("[PROFILE-ASYNC] %s: %.3f ms"):format(name, elapsed))
        end)

        if not ok then
            error(result)
        end
        return result
    end
end

return M
