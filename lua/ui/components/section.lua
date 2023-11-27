Section = {}
Section.__index = Section

--- @class Section
--- @field title string
--- @field content string[]
--- @field folded boolean
--- @field write function(bufnr: number):void
--- @param title string
--- @param content string[]
function Section.new(title, content, folded)
    local self = setmetatable({}, Section)
    self.title = title
    self.content = content
    self.folded = folded
    return self
end

--- Write the section to the given buffer.
--- @param bufnr number
--- @param folded boolean
function Section:write(bufnr, folded)
    local bufnr_lines = vim.api.nvim_buf_line_count(bufnr)
    local title_start = bufnr_lines
    local content_start = title_start + 1
    local content_end = content_start + #self.content

    vim.api.nvim_buf_set_lines(bufnr, title_start, -1, false, { self.title })

    local content = {}
    for _, line in ipairs(self.content) do
        table.insert(content, "> " .. line)
    end

    vim.api.nvim_buf_set_lines(bufnr, content_start, content_end, false, content)

    local fold_start = tostring(content_start + 1)
    vim.cmd(fold_start .. "," .. tostring(content_end) .. "fold")

    if not self.folded then
        vim.cmd(fold_start .. "foldopen")
    end
end

-- Return the module
return Section
