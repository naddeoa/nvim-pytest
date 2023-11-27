local sign_lib = require("signs.sign_lib")
local Window = require("ui.components.window")
local Section = require("ui.components.section")
local sign_consts = require("signs.sign_consts")

--- @class TestResult
--- @field results string[]
--- @field failed boolean
local myStruct = {
    results = {},
    failed = false,
}

--- @param test_name string
--- @param failed boolean
local function get_pretty_test_name(test_name, failed)
    local pretty_test_name = ""
    if failed then
        pretty_test_name = sign_consts.RAW_SIGNS.failed .. " " .. test_name
    else
        pretty_test_name = sign_consts.RAW_SIGNS.passed .. " " .. test_name
    end

    return pretty_test_name
end

App = {}
App.__index = App

--- @class App
--- @field test_results table<string, table<string, TestResult>>
--- @field window Window
--- @field register_test_result function(file_path: string, test_name: string, result: string[]):void
--- @field run_test function(file_path: string, test_name: string, line_number: number):void
--- @field run_tests function(file_path: string, test_names: table<string, number>):void
--- @field show_test_results function(file_path: string, test_name: string):void
function App.new()
    local self = setmetatable({}, App)
    self.test_results = {}
    self.window = Window.new()
    return self
end

--- Add a test result to the app.
--- @param file_path string the path of the file the test was run in
--- @param test_name string the name of the test
--- @param result string[] the result of a test run
--- @param failed boolean whether or not the test failed
function App:register_test_result(file_path, test_name, result, failed)
    if not self.test_results[file_path] then
        self.test_results[file_path] = {}
    end

    self.test_results[file_path][test_name] = {
        results = result,
        failed = failed,
    }
end

--- Run the test with the given name in the given file.
--- @param file_path string the path of the file to run the test in
--- @param test_name string the name of the test to run
--- @param line_number number the line number of the test to run
function App:run_test(file_path, test_name, line_number)
    local bufnr = vim.api.nvim_get_current_buf()
    local command = "pytest " .. file_path .. "::" .. test_name

    --- @type table<string>
    local results = {}

    local sign = sign_lib.in_progress(line_number, bufnr)
    vim.fn.jobstart(command, {
        on_stdout = function(j, data, event)
            vim.list_extend(results, data)
        end,
        on_stderr = function(j, data, event)
            vim.list_extend(results, data)
        end,
        on_exit = function(j, exit_code, event)
            sign:remove()
            local failed = exit_code ~= 0
            if exit_code == 0 then
                table.insert(results, 1, "Tests Passed.")
                sign_lib.passed(line_number, bufnr)
            else
                table.insert(results, 1, "Tests Failed.")
                sign_lib.failed(line_number, bufnr)
            end

            self:register_test_result(file_path, test_name, results, failed)
        end,
    })
end

--- Run the tests in the given file.
--- This kicks off one job for every test in the test_names table ands
--- marks the lines with the appropriate sign.
--- @param file_path string the path of the file to run the tests in
--- @param test_names table<string, number> the table of test names and their line numbers
function App:run_tests(file_path, test_names)
    -- Call run_tests with each test/row
    for test_name, line_number in pairs(test_names) do
        self:run_test(file_path, test_name, line_number)
    end
end

--- Get the results for the given test.
--- @param file_path string the path of the file to get the results for
--- @param test_name string the name of the test to get the results for
--- @return TestResult
function App:get_results(file_path, test_name)
    return self.test_results[file_path][test_name]
end

--- Show the most recent results for the given test.
--- @param file_path string the path of the file to show the results for
--- @param test_name string the name of the test to show the results for
--- @return nil
function App:show_test_results(file_path, test_name)
    --- @type TestResult
    local results = self:get_results(file_path, test_name)
    if not results then
        return
    end

    self.window:show()
    local pretty_test_name = get_pretty_test_name(test_name, results.failed)
    self.window:show_section(Section.new(pretty_test_name, results.results, false))
end

--- Show the most recent results for the given file.
--- @param file_path string the path of the file to show the results for
function App:show_file_test_results(file_path)
    --- @type table<string, TestResult>
    local results = self.test_results[file_path]
    if not results then
        return
    end

    --- @type Section[]
    local sections = {}
    for test_name, result in pairs(results) do
        local pretty_test_name = get_pretty_test_name(test_name, result.failed)
        table.insert(sections, Section.new(pretty_test_name, result.results, true))
    end

    self.window:show()
    self.window:show_sections(sections)
end

return App
