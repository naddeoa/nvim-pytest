Sign = {}
Sign.__index = Sign

--- Constructor for the Sign class
--- @class Sign
--- @field id integer The buffer number
--- @field bufnr integer The line number to start the sign
--- @field line integer The line number to start the sign
--- @field remove function():void The function to remove the sign
function Sign.new(id, bufnr, line)
    local self = setmetatable({}, Sign)
    self.id = id
    self.bufnr = bufnr
    self.line = line
    return self
end

--- Function to remove the sign
function Sign:remove()
    vim.fn.sign_unplace("unit", { buffer = self.bufnr, id = self.id })
end

return Sign
