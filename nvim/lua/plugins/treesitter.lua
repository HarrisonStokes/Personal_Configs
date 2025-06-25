return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Core languages only - let Mason handle the rest
      ensure_installed = {
        "html", "xml", "css", "scss",
        "javascript", "typescript", "tsx",
        "php", "python", "java",
        "markdown", "markdown_inline",
        "yaml", "json", "jsonc",
        "c", "cpp", "rust", "lua", "vim", "bash",
        "dockerfile"
      },
      
      auto_install = true,
      
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false, -- Reduced overhead
      },
      
      indent = {
        enable = true,
        disable = { "python", "yaml" }
      },
      
      -- Simplified text objects
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    })
    
    -- Single augroup for all treesitter autocmds
    local augroup = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true })
    
    -- Simplified filetype detection - only essential ones
    vim.filetype.add({
      extension = {
        jsx = "javascriptreact",
        tsx = "typescriptreact",
        vue = "vue",
        svelte = "svelte",
      },
    })
    
    -- Single autocmd for web language settings
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { "html", "xml", "vue", "svelte", "jsx", "tsx" },
      callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
        vim.opt_local.foldlevel = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.expandtab = true
      end,
    })
  end,
}
