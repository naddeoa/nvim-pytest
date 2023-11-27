local queries = require("queries")
local App = require("ui.app")

local api = vim.api

local app = App.new()

local M = {}

-- Function to run PyTest on the current file
function M.pytest_run_current_file()
    local tests = queries.get_all_test_names()

    if not tests then
        return
    end

    local current_file = api.nvim_buf_get_name(0)
    app:run_tests(current_file, tests)
end

function M.pytest_run_current_function()
    local function_name, row = queries.get_test_at_cursor()

    if not function_name or not row then
        return
    end

    -- Running PyTest for the specific function
    local current_file = api.nvim_buf_get_name(0)
    app:run_test(current_file, function_name, row)
end

function M.show_last_results()
    local function_name, row = queries.get_test_at_cursor()

    if not function_name or not row then
        return
    end

    local file_path = api.nvim_buf_get_name(0)

    app:show_test_results(file_path, function_name)
end

function M.show_current_file_results()
    local file_path = api.nvim_buf_get_name(0)

    app:show_file_test_results(file_path)
end

function M.default_keymaps()
    api.nvim_set_keymap("n", "tF", ":silent UnitRunCurrentFile<CR>", { noremap = true, silent = true })
    api.nvim_set_keymap("n", "tf", ":silent UnitRunCurrentFunction<CR>", { noremap = true, silent = true })
    api.nvim_set_keymap("n", "ts", ":silent UnitShowLastResultsCurrentFunction<CR>", { noremap = true, silent = true })
    api.nvim_set_keymap("n", "tS", ":silent UnitShowResultsCurrentFile<CR>", { noremap = true, silent = true })
end

-- Registering the commands
function M.setup()
    api.nvim_create_user_command("UnitRunCurrentFile", M.pytest_run_current_file, {})
    api.nvim_create_user_command("UnitRunCurrentFunction", M.pytest_run_current_function, {})
    api.nvim_create_user_command("UnitShowLastResultsCurrentFunction", M.show_last_results, {})
    api.nvim_create_user_command("UnitShowResultsCurrentFile", M.show_current_file_results, {})
end

return M
