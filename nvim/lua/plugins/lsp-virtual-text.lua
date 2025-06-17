return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()
    
    -- Disable lsp_lines by default, use built-in virtual_text
    vim.diagnostic.config({
      virtual_text = {
        prefix = "■",
        spacing = 4,
        source = "if_many",
      },
      virtual_lines = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
    
    -- Toggle between inline virtual text and lsp_lines
    vim.keymap.set("n", "<leader>l", function()
      local config = vim.diagnostic.config() or {}
      if config.virtual_lines then
        -- Switch to inline
        vim.diagnostic.config({ 
          virtual_text = {
            prefix = "■",
            spacing = 4,
            source = "if_many",
          }, 
          virtual_lines = false 
        })
        print("Switched to inline diagnostics")
      else
        -- Switch to lsp_lines
        vim.diagnostic.config({ 
          virtual_text = false, 
          virtual_lines = true 
        })
        print("Switched to line diagnostics")
      end
    end, { desc = "Toggle between inline and line diagnostics" })
  end,
}
