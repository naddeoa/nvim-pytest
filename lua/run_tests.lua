local sign_lib = require("signs.sign_lib")

local function open_vertical_split()
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

--- Run the test with the given name in the given file.
--- @param file_path string @the path of the file to run the test in
--- @param test_name string @the name of the test to run
--- @param line_number number @the line number of the test to run
local function run_test(file_path, test_name, line_number)
	local command = "pytest " .. file_path .. "::" .. test_name

	local results = {}
	local sign = sign_lib.in_progress(line_number, vim.api.nvim_get_current_buf())
	vim.fn.jobstart(command, {
		on_stdout = function(j, data, event)
			vim.list_extend(results, data)
		end,
		on_stderr = function(j, data, event)
			vim.list_extend(results, data)
		end,
		on_exit = function(j, exit_code, event)
			sign:remove()
			if exit_code == 0 then
				table.insert(results, 1, "Tests Passed.")
				sign_lib.passed(line_number, vim.api.nvim_get_current_buf())
			else
				table.insert(results, 1, "Tests Failed.")
				sign_lib.failed(line_number, vim.api.nvim_get_current_buf())
				-- write_to_buffer(open_vertical_split(), results)
			end
		end,
	})
end

--- Run the tests in the given file.
--- This kicks off one job for every test in the test_names table ands
--- marks the lines with the appropriate sign.
--- @param file_path string @the path of the file to run the tests in
--- @param test_names table<string, number> @the table of test names and their line numbers
local function run_tests(file_path, test_names)
	-- Call run_tests with each test/row
	for test_name, line_number in pairs(test_names) do
		run_test(file_path, test_name, line_number)
	end
end

return {
	run_tests = run_tests,
	run_test = run_test,
}
