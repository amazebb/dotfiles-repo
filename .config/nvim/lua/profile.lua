local M = {}

function M.profile(name, fn)
    return function(...)
        local start = vim.uv.hrtime()
        local ok, result = pcall(fn, ...)
        local elapsed = (vim.uv.hrtime() - start) / 1e6

        vim.print(("[SYNC ] %s: %.3f ms"):format(name, elapsed))

        if not ok then
            error(result)
        end
        return result
    end
end

function M.profile_async(name, fn)
    return function(...)
        local start = vim.uv.hrtime()
        local ok, result = pcall(fn, ...)
        local elapsed = (vim.uv.hrtime() - start) / 1e6

        vim.schedule(function()
            vim.print(("[ASYNC] %s: %.3f ms"):format(name, elapsed))
        end)

        if not ok then
            error(result)
        end
        return result
    end
end

return M

-- -- init.lua or any plugin file
-- local P = require("profile")        -- P.profile and P.async
--
-- -- 1. Profile a normal synchronous function
-- local function compute_heavy()
--   local sum = 0
--   for i = 1, 5e7 do
--     sum = sum + math.sin(i)
--   end
--   return sum
-- end
--
-- -- Wrap it once (idiomatic)
-- compute_heavy = P.profile("compute_heavy", compute_heavy)
--
-- -- Now every call is automatically timed
-- compute_heavy()     -- → [SYNC  ] compute_heavy: 187.342 ms
-- compute_heavy()     -- → [SYNC  ] compute_heavy: 186.971 ms
--
--
-- -- 2. Profile an async callback (timer, LSP, uv)
-- local timer = vim.uv.new_timer()
-- timer:start(1000, 0, P.async("timer_callback", function()
--   vim.loop.sleep(50)        -- simulate work
--   print("Timer fired!")
-- end))
--
-- -- 3. Profile a user command
-- vim.api.nvim_create_user_command("HeavyCmd", P.profile("HeavyCmd", function()
--   vim.fn.system({ "sleep", "0.1" })
--   print("Command done")
-- end), {})
--
-- -- Call it
-- :HeavyCmd                   -- → [SYNC  ] HeavyCmd: 102.451 ms
--
--
-- -- 4. One-off inline profiling (no permanent wrap)
-- local function once()
--   local slow = P.profile("once.slow_block", function()
--     vim.loop.sleep(200)
--   end)
--   slow()                    -- prints and returns nil
-- end
-- once()                      -- → [SYNC  ] once.slow_block: 200.113 ms
