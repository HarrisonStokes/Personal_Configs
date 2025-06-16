return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "cpp",
        "rust",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "lua",
        "vim",
        "bash",
        "json",
        "yaml",
        "markdown",
        "verilog",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  end,
}
