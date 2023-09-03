local M = {}
-- from https://stackoverflow.com/questions/1426954/split-string-in-lua
local function split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table, cap)
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

local values = nil
M.setup = function(opts)
    values = require("themer.data")
    for k, v in pairs(values) do
        if values[k].name == "vim" or values[k].name == "neovim" or values[k].name == "nvim" then
            values[k].name = split(values[k].githubUrl, "/")[1]
        end
    end
    vim.api.nvim_create_user_command("Themer", function(opts)
        local lines = {}
        for k, v in pairs(values) do
            lines[k] = v.name
        end
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        local width = vim.o.columns - 10
        local height = vim.o.lines - 10
        local offsetX = 5
        local offsetY = 5
        vim.api.nvim_open_win(buf, true, {
            relative = "win",
            width = width,
            height = height,
            row = 10,
            col = 10,
            style = "",
            bufpos = { offsetX, offsetY },
        })
    end, {
    })
end

return M
