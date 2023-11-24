local ts = require("nvim-treesitter")
local ts_utils = require("nvim-treesitter.ts_utils")
local sign_lib = require("signs.sign_lib")
local queries = require("queries")
local run_tests = require("run_tests")

local api = vim.api

local M = {}

-- Function to run PyTest on the current file
function M.pytest_run_current_file()
	local tests = queries.get_all_test_names()

	if not tests then
		return
	end

	local current_file = api.nvim_buf_get_name(0)
	run_tests.run_tests(current_file, tests)
end

function M.pytest_run_current_function()
	local function_name, row = queries.get_test_at_cursor()

	if not function_name or not row then
		return
	end

	-- Running PyTest for the specific function
	local current_file = api.nvim_buf_get_name(0)
	run_tests.run_test(current_file, function_name, row)
end

-- Function to update the sign column with test results
function M.update_test_results()
	-- TODO: Parse PyTest output and update the sign column
end

-- Registering the commands
function M.setup()
	api.nvim_create_user_command("PyTestRunCurrentFile", M.pytest_run_current_file, {})
	api.nvim_create_user_command("PyTestRunCurrentFunction", M.pytest_run_current_function, {})
end

return M
