return {
  "ngtuonghy/live-server-nvim",
  event = "VeryLazy",
  build = ":LiveServerInstall",
  config = function()
    require("live-server-nvim").setup({
      custom = {
        "--port=8080",
        "--no-css-inject",
      },
      serverPath = vim.fn.stdpath("data") .. "/live-server/",
      open = "folder", -- folder|cwd
    })

    -- Keymaps that match your existing style
    local keymap = vim.keymap.set
    keymap("n", "<leader>ls", "<cmd>LiveServerStart<cr>", { desc = "Start Live Server" })
    keymap("n", "<leader>lq", "<cmd>LiveServerStop<cr>", { desc = "Stop Live Server" })
    keymap("n", "<leader>lr", "<cmd>LiveServerToggle<cr>", { desc = "Toggle Live Server" })
    
    -- Alternative function-based keymap for toggle
    keymap("n", "<leader>lt", function() 
      require("live-server-nvim").toggle() 
    end, { desc = "Toggle Live Server (function)" })
  end,
}
