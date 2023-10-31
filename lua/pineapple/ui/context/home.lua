local makeContext = require("pineapple.ui.context.makeContext")

local homeCtx = {
}
local data = {}

local themeStartLine = 3

function homeCtx:filterEntries()
end

---@return Keymap[]
function homeCtx:getKeymaps()
    ---@type Keymap[]
    local ret = {
        {
            key = "f",
            desc = "Filter",
            isGroup = true,
            subKeymaps = {
                {
                    key = "t",
                    fn = function()
                        local text = vim.fn.input("Yo gimme a name: ")
                        local newData = {}
                        for _, v in ipairs(data.disp) do
                            if vim.fn.stridx(v.name, text) ~= -1 or vim.fn.stridx(v.description, text) ~= -1 or vim.fn.stridx(v.githubUrl, text) ~= -1 then
                                table.insert(newData, v)
                            end
                        end
                        data.disp = newData
                        self.render()
                    end,
                    desc = "by text",
                    isGroup = false
                },
                {
                    key = "v",
                    desc = "by variants",
                    fn = function()
                        local text = vim.fn.input("Yo gimme a name: ")
                        local newData = {}
                        for _, v in ipairs(data.disp) do
                            local variants = {}
                            for _, vimColorScheme in pairs(v.vimColorSchemes) do
                                if vim.fn.stridx(vimColorScheme.name, text) ~= -1 then
                                    table.insert(variants, vimColorScheme)
                                end
                            end
                            if #variants > 0 then
                                local newRow = vim.fn.deepcopy(v)
                                newRow.vimColorSchemes = variants
                                table.insert(newData, newRow)
                            end
                        end
                        data.disp = newData
                        self.render()
                    end,
                    isGroup = false
                },
                {
                    key = "c",
                    desc = "clear",
                    fn = function()
                        data.disp = data.org
                        self.render()
                    end,
                    isGroup = false,
                },
                {
                    key = "d",
                    desc = "dark",
                    fn = function()
                        local newData = {}
                        for _, v in ipairs(data.disp) do
                            local variants = {}
                            for _, vimColorScheme in pairs(v.vimColorSchemes) do
                                if vimColorScheme.data ~= nil and vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark.vimNumber ~= nil then
                                    table.insert(variants, vimColorScheme)
                                end
                            end
                            if #variants > 0 then
                                local newRow = vim.fn.deepcopy(v)
                                newRow.vimColorSchemes = variants
                                table.insert(newData, newRow)
                            end
                        end
                        data.disp = newData
                        self.render()
                    end,
                    isGroup = false,
                },
                {
                    key = "l",
                    desc = "light",
                    fn = function()
                        local newData = {}
                        for _, v in ipairs(data.disp) do
                            local variants = {}
                            for _, vimColorScheme in pairs(v.vimColorSchemes) do
                                if vimColorScheme.data ~= nil and vimColorScheme.data.light ~= nil and vimColorScheme.data.light.vimNumber ~= nil then
                                    table.insert(variants, vimColorScheme)
                                end
                            end
                            if #variants > 0 then
                                local newRow = vim.fn.deepcopy(v)
                                newRow.vimColorSchemes = variants
                                table.insert(newData, newRow)
                            end
                        end
                        data.disp = newData
                        self.render()
                    end,
                    isGroup = false,
                },

            },
        },
        {
            key = "i",
            desc = "Install",
            fn = function()
                local line = vim.fn.line(".")
                local index = line - #self:getKeymaps() - 3
                if index < 1 or index > #data.disp then
                    print("Not hovering over a theme")
                    return
                end
                local theme = data.disp[index]
                require("pineapple.installer").install(theme.githubUrl)
            end,
            isGroup = false,
        }
    }
    return ret
end

function homeCtx:getEntryKey()
    return "H"
end

function homeCtx:addHighlights(_, _, _)

end

function homeCtx:getLines(_)
    local ret = {}

    -- for _, v in ipairs(remapLines) do
    --     table.insert(ret, v)
    -- end
    themeStartLine = 3 + #self:getKeymaps()
    for _, v in ipairs(data.disp) do
        table.insert(ret, "  " .. v.name)
    end
    return ret
end

function homeCtx:setup()
    local orgData = require("pineapple.data")
    local values = {}
    for _, v in pairs(orgData) do
        local canInsert = true
        local tempVal = v
        if v.vimColorSchemes ~= nil then
            local newVimColorSchemes = {}
            for _, vimColorScheme in pairs(v.vimColorSchemes) do
                if vimColorScheme.data ~= nil and ((vimColorScheme.data.light ~= nil and vimColorScheme.data.light.vimNumber ~= nil) or (vimColorScheme.data.dark ~= nil and vimColorScheme.data.dark.vimNumber ~= nil)) then
                    table.insert(newVimColorSchemes, vimColorScheme)
                end
            end
            if #newVimColorSchemes == 0 then
                canInsert = false
            end
            tempVal.vimColorSchemes = newVimColorSchemes
        else
            canInsert = false
        end
        if canInsert then
            table.insert(values, tempVal)
        end
    end
    for k, _ in pairs(values) do
        values[k].githubUrl = values[k].githubUrl:gsub("https://github.com/", "")
        if values[k].name == "vim" or values[k].name == "neovim" or values[k].name == "nvim" then
            values[k].name = vim.fn.split(values[k].githubUrl, "/")[1]
        end
    end
    data = {
        org = values,
        disp = values,
    }
end

function homeCtx:setContext(_)
    return {
        {}
    }
end

function homeCtx:setExitContext(_)
    if vim.fn.line(".") - themeStartLine < 1 then
        return { "sdf" }
    end

    return {
        data.disp[vim.fn.line(".") - themeStartLine],
    }
end

function homeCtx:getName()
    return "Pineapple"
end

local M = makeContext.newContext(homeCtx)

M:addSubContext(require("pineapple.ui.context.view"))

return M
