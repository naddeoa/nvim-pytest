local ts_utils = require("nvim-treesitter.ts_utils")

--- Query for all function names in a file
--- @return table<string, number>: A table of function names and their line numbers
local function get_all_test_names()
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(bufnr)
	local tree = parser:parse()[1]

	local function_names = {}
	local query = vim.treesitter.query.parse(
		"python", -- replace with the appropriate language
		[[
            (function_definition name: (identifier) @names)
        ]]
	)

	for id, node, metadata in query:iter_captures(tree:root(), bufnr) do
		local name_text = vim.treesitter.get_node_text(node, bufnr)
		-- get range stuff
		local start_row, start_col, end_row, end_col = node:range()

		if string.find(name_text, "test") then
			function_names[name_text] = start_row
		end
	end

	return function_names
end

--- Query for the function name at the cursor, if one exists
--- @return string?, number?: the function name and the line number
local function get_test_at_cursor()
	local node = ts_utils.get_node_at_cursor()
	if not node then
		return nil, nil
	end

	-- Finding the function node
	while node do
		if node:type() == "function_definition" then
			break
		end
		node = node:parent()
	end

	if not node then
		return nil, nil
	end

	-- Traverse the child nodes for the identifier
	local function_name_node
	for child in node:iter_children() do
		if child:type() == "identifier" then
			-- Found the name node
			function_name_node = child
			break
		end
	end

	if not function_name_node then
		return nil, nil
	end

	-- Extracting the function name
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = function_name_node:range()
	local name = vim.treesitter.get_node_text(function_name_node, bufnr)
	return name, start_row
end

return {
	get_all_test_names = get_all_test_names,
	get_test_at_cursor = get_test_at_cursor,
}
