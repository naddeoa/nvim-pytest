vim.cmd("highlight UnitSelectedFilter guifg=black guibg=white") -- Red text color

--- Returns the start/end column of the given option in the given filter, or nil if it isn't there.
--- @param filter string
--- @param option string
--- @return number|nil, number|nil
local function get_start_end_col(filter, option)
    local start = string.find(filter, option, 1, true)
    if not start then
        return nil, nil
    end

    local end_ = start + string.len(option)
    return start, end_
end

Filter = {}
Filter.__index = Filter

--- @class Filter
--- @field options table<string, string> A table of labels to keybind. Pressing the keybind will result
--- in the label being passed to the on_select callback.
--- @field on_select function(option: string):void
--- @field write function(bufnr: number):void
--- @field selected_option string|nil
--- @field option_labels table<string, string> A table of labels to display in the filter. The keybind
--- @param options table<string, string>
--- @param on_select function(option: string):void
function Filter.new(options, on_select)
    local self = setmetatable({}, Filter)
    self.options = options
    self.on_select = on_select
    self.selected_option = nil

    --- @type table<string, string>
    local option_labels = {}
    for option, keybind in pairs(self.options) do
        option_labels[option] = string.format(" [(%s) %s] ", keybind, option)
    end
    self.option_labels = option_labels

    return self
end

--- @param option string An option from the options table
function Filter:set_selected_option(option)
    if not self.options[option] then
        return
    end

    self.selected_option = option
end

--- Write the filter to the given buffer.
--- @param bufnr number
function Filter:write(bufnr)
    local bufnr_lines = vim.api.nvim_buf_line_count(bufnr)
    local start = bufnr_lines - 1

    local filter_line = ""
    for _, label in pairs(self.option_labels) do
        filter_line = filter_line .. label
    end

    vim.api.nvim_buf_set_lines(bufnr, start, -1, true, { filter_line })

    local default_selected, _ = next(self.options)
    local selected_option = self.selected_option or default_selected
    local selected_label = self.option_labels[selected_option]

    local start_col, end_col = get_start_end_col(filter_line, selected_label)
    if not start_col or not end_col then
        return
    end

    vim.api.nvim_buf_add_highlight(bufnr, -1, "UnitSelectedFilter", bufnr_lines - 1, start_col, end_col)
end

return Filter
