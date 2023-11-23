local Sign = require("signs.sign")
local sign_consts = require("signs.sign_consts")

--- Add a sign to a line
--- @param bufnr number
--- @param line_start number
--- @param sign_name string
--- @return Sign
local function add_sign(bufnr, line_start, sign_name)
	local id = vim.fn.sign_place(0, sign_consts.GROUP, sign_name, bufnr, { lnum = line_start + 1 })
	return Sign.new(id, bufnr, line_start)
end

--- Show the in progress sign on a line
--- @param line_number number
--- @param bufnr number
--- @return Sign
local function in_progress(line_number, bufnr)
	return add_sign(bufnr, line_number, sign_consts.SIGN_NAMES.inprogress)
end

--- Show the passed sign on a line
--- @param line_number number
--- @param bufnr number
--- @return Sign
local function passed(line_number, bufnr)
	return add_sign(bufnr, line_number, sign_consts.SIGN_NAMES.passed)
end

--- Show the failed sign on a line
--- @param line_number number
--- @param bufnr number
--- @return Sign
local function failed(line_number, bufnr)
	return add_sign(bufnr, line_number, sign_consts.SIGN_NAMES.failed)
end

return {
	in_progress = in_progress,
	passed = passed,
	failed = failed,
}
