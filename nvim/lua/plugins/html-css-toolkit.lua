return {
  "mattn/emmet-vim",
  ft = { 
    "html", "xml", "css", "scss", "sass",
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "vue", "svelte", "php"
  },
  config = function()
    -- Simplified Emmet settings
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_leader_key = '<C-y>'
    
    -- Essential settings only
    vim.g.user_emmet_settings = {
      variables = { lang = 'en', charset = 'UTF-8' },
      html = {
        default_attributes = {
          input = { type = 'text' },
          img = { src = '', alt = '' },
          a = { href = '' },
        }
      },
      jsx = {
        attribute_name = { class = 'className', ['for'] = 'htmlFor' }
      }
    }

    -- Single augroup for all Emmet autocmds
    local augroup = vim.api.nvim_create_augroup("EmmetConfig", { clear = true })
    
    -- Single autocmd for all supported filetypes
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { 
        "html", "xml", "css", "scss", "sass",
        "javascript", "javascriptreact", "typescript", "typescriptreact",
        "vue", "svelte", "php"
      },
      callback = function()
        vim.cmd("EmmetInstall")
        
        -- Essential mappings only
        local opts = { buffer = true, silent = true }
        vim.keymap.set({ "i", "n" }, "<C-y>,", "<plug>(emmet-expand-abbr)", opts)
        vim.keymap.set("v", "<C-y>w", "<plug>(emmet-wrap-with-abbreviation)", opts)
        vim.keymap.set({ "i", "n" }, "<C-y>/", "<plug>(emmet-toggle-comment)", opts)
      end,
    })
  end,
}
