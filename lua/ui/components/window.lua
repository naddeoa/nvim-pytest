local fold = require("keys.fold")
local Section = require("ui.components.section")

Window = {}
Window.__index = Window

local function modify(buf, fn)
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    fn()
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

--- @class Window
--- @field win integer|nil
--- @field show function():void
--- @field open function(buf: number):void
--- @field show_section function(section: Section):void
function Window.new()
    local self = setmetatable({}, Window)
    self.win = nil
    return self
end

--- @param buf number
function Window:set_keybinds(buf)
    vim.keymap.set("n", "<CR>", fold.toggle_fold, { noremap = true, silent = true, buffer = buf })
    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(self.win, true)
        self.win = nil
    end, { noremap = true, silent = true, buffer = buf })
end

function Window:show()
    -- Get the dimensions of the entire Neovim window
    local screen_width = vim.o.columns
    local screen_height = vim.o.lines

    -- Calculate 80% of the screen size
    local width = math.floor(screen_width * 0.8)
    local height = math.floor(screen_height * 0.8)

    -- Calculate the starting position to center the window
    local col = math.floor((screen_width - width) / 2)
    local row = math.floor((screen_height - height) / 2)

    -- Create a buffer for the floating window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Create the floating window
    self.win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    })

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_win_set_option(self.win, "foldmethod", "manual")
    self:set_keybinds(buf)
end

--- @param section Section
function Window:show_section(section)
    if not self.win then
        self:show()
    end

    local buf = vim.api.nvim_win_get_buf(self.win)

    modify(buf, function()
        section:write(buf)
    end)
end

function Window:show_sections(sections)
    local buf = vim.api.nvim_win_get_buf(self.win)
    for _, section in ipairs(sections) do
        self:show_section(section)
        -- Add a blank line between sections
        modify(buf, function()
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
        end)
    end
end

return Window
