local RAW_SIGNS = {
    inprogress = "↻",
    passed = "🟢",
    failed = "🔴",
}

vim.fn.sign_define("inprogress", { text = RAW_SIGNS.inprogress, texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("passed", { text = RAW_SIGNS.passed, texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("failed", { text = RAW_SIGNS.failed, texthl = "", linehl = "", numhl = "" })

local SIGNS = {
    inprogress = "inprogress",
    passed = "passed",
    failed = "failed",
}

local GROUP = "unit"

return {
    RAW_SIGNS = RAW_SIGNS,
    SIGN_NAMES = SIGNS,
    GROUP = GROUP,
}
