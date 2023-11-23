local ts = require("nvim-treesitter")
local ts_utils = require("nvim-treesitter.ts_utils")
local sign_lib = require("signs.sign_lib")

local api = vim.api

local M = {}

-- Function to run PyTest on the current file
function M.pytest_run_current_file()
	-- TODO: Implement function
end

local function log(msg)
	vim.api.nvim_echo({ { msg, "None" } }, true, {})
end

local function open_vertical_split(bufnr)
	vim.cmd("vnew | wincmd L") -- Open a new vertical split and move it to the right
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
	return bufnr
end

local function write_to_buffer(bufnr, lines)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

function M.pytest_run_current_function()
	local node = ts_utils.get_node_at_cursor()
	if not node then
		return
	else
	end

	-- Finding the function node
	while node do
		if node:type() == "function_definition" then
			break
		end
		node = node:parent()
	end

	if not node then
		return
	end

	-- Traverse the child nodes for the identifier
	local function_name_node
	for child in node:iter_children() do
		print("child node type " .. child:type())
		if child:type() == "identifier" then
			-- Found the name node
			function_name_node = child
			break
		end
	end

	if not function_name_node then
		return
	end
	print(function_name_node)

	-- Extracting the function name
	local bufnr = vim.api.nvim_get_current_buf()
	local function_name = vim.treesitter.get_node_text(function_name_node, bufnr)
	-- Unpack function_name_node ranges

	if not function_name then
		return
	end
	local start_row, start_col, end_row, end_col = function_name_node:range()

	-- Running PyTest for the specific function
	local current_file = api.nvim_buf_get_name(0)
	local command = "pytest " .. current_file .. "::" .. function_name

	local results = {}
	local sign = sign_lib.in_progress(start_row, bufnr)
	vim.fn.jobstart(command, {
		on_stdout = function(j, data, event)
			vim.list_extend(results, data)
		end,
		on_stderr = function(j, data, event)
			vim.list_extend(results, data)
		end,
		on_exit = function(j, exit_code, event)
            vim.print(sign)
			sign:remove()
			if exit_code == 0 then
				table.insert(results, 1, "Tests Passed.")
				sign_lib.passed(start_row, bufnr)
			else
				table.insert(results, 1, "Tests Failed.")
				sign_lib.failed(start_row, bufnr)
				write_to_buffer(open_vertical_split(), results)
			end
		end,
	})
end

-- Function to run PyTest on the current class
function M.pytest_run_current_class()
	-- TODO: Use Treesitter to find the current class
end

-- Function to update the sign column with test results
function M.update_test_results()
	-- TODO: Parse PyTest output and update the sign column
end

-- Registering the commands
function M.setup()
	api.nvim_create_user_command("PyTestRunCurrentFile", M.pytest_run_current_file, {})
	api.nvim_create_user_command("PyTestRunCurrentFunction", M.pytest_run_current_function, {})
	api.nvim_create_user_command("PyTestRunCurrentClass", M.pytest_run_current_class, {})
end

return M
