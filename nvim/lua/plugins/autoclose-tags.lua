return {
  "windwp/nvim-ts-autotag",
  ft = { 
    "html", "xhtml", "xml", "svg", "xaml",
    "javascript", "javascriptreact", "typescript", "typescriptreact", "jsx", "tsx",
    "vue", "svelte", "astro", "solid",
    "php", "erb", "ejs", "handlebars", "mustache", "twig", "blade", "jinja", "django",
    "jsp", "asp", "razor", "liquid",
    "markdown", "mdx"
  },
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true
      },
      
      per_filetype = {
        ["html"] = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
        ["xml"] = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
        ["vue"] = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
        ["svelte"] = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
        ["jsx"] = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
        ["tsx"] = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
      }
    })
    
    local augroup = vim.api.nvim_create_augroup("CustomAutoclose", { clear = true })
    
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { "handlebars", "mustache", "twig", "blade", "jinja", "django", "liquid", "jsp", "asp", "razor", "ejs" },
      callback = function()
        local opts = { buffer = true, silent = true }
        local filetype = vim.bo.filetype
        
        -- Template-specific mappings
        if filetype == "handlebars" or filetype == "mustache" then
          vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
        elseif filetype == "twig" or filetype == "jinja" or filetype == "django" then
          vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
          vim.keymap.set("i", "{%", "{%  %}<Left><Left><Left>", opts)
        elseif filetype == "blade" then
          vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
          vim.keymap.set("i", "{!!", "{!!  !!}<Left><Left><Left><Left>", opts)
        end
      end,
    })
  end,
}
