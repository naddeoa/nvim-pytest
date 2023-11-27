local function toggle_fold()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local is_fold_closed = vim.fn.foldclosed(current_line)

	if is_fold_closed == -1 then
		-- If the fold is open, close it
		vim.cmd(current_line .. "foldclose")
	else
		-- If the fold is closed, open it
		vim.cmd(is_fold_closed .. "foldopen")
	end
end

return {
	toggle_fold = toggle_fold,
}
