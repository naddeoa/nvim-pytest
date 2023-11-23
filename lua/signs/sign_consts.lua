vim.fn.sign_define("inprogress", { text = "↻", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("passed", { text = "🟢", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("failed", { text = "🔴", texthl = "", linehl = "", numhl = "" })

local SIGNS = {
    inprogress = "inprogress",
    passed = "passed",
    failed = "failed",
}

local GROUP = "unit"


return {
    SIGN_NAMES = SIGNS,
    GROUP = GROUP,
}
