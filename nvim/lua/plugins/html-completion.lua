return {
  -- Enhanced completion sources
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    dependencies = "nvim-cmp",
  },
  
  -- Tailwind CSS completion and colorization
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    dependencies = "nvim-cmp",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  -- CSS completion enhancements
  {
    "Jezda1337/nvim-html-css",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("html-css"):setup({
        file_extensions = { "css", "sass", "less", "scss", "html", "vue", "svelte", "jsx", "tsx" },
        style_sheets = {}
      })
    end,
    ft = { "html", "css", "sass", "scss", "less", "vue", "svelte", "jsx", "tsx" },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "williamboman/mason.nvim" },
    config = function()
      -- Only add HTML-specific enhancements here
      
      local augroup = vim.api.nvim_create_augroup("HTMLEnhancements", { clear = true })
      
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = { "html", "xml", "vue", "svelte" },
        callback = function()
          -- HTML-specific settings only
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.expandtab = true
        end,
      })
    end,
  },

  -- Template language support - simplified
  {
    "mustache/vim-mustache-handlebars",
    ft = { "mustache", "handlebars" }
  },

  {
    "tpope/vim-liquid",
    ft = { "liquid" }
  },
}
