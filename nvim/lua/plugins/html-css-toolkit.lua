return {
  "mattn/emmet-vim",
  ft = { 
    -- Web Languages
    "html", "xhtml", "xml", "css", "scss", "sass", "less",
    -- JavaScript/TypeScript
    "javascript", "javascriptreact", "typescript", "typescriptreact", "jsx", "tsx",
    -- Frameworks & Libraries
    "vue", "svelte", "astro", "solid",
    -- Template Languages
    "php", "erb", "ejs", "handlebars", "mustache", "twig", "blade", "jinja", "django",
    -- Server-side
    "jsp", "asp", "razor", "liquid",
    -- Markup & Config
    "markdown", "mdx", "svg", "xaml", "plist"
  },
  config = function()
    -- Enable Emmet globally but activate per filetype
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_leader_key = '<C-y>'
    
    -- Comprehensive Emmet settings for all supported languages
    vim.g.user_emmet_settings = {
      variables = {
        lang = 'en',
        locale = 'en-US',
        charset = 'UTF-8'
      },
      
      -- HTML/XHTML
      html = {
        default_attributes = {
          option = { value = nil },
          textarea = { id = nil, name = nil, cols = 10, rows = 10 },
          input = { id = nil, name = nil, type = 'text' },
          img = { src = '', alt = '', width = nil, height = nil },
          a = { href = '' },
          div = { class = nil },
          span = { class = nil },
          button = { type = 'button' },
          form = { method = 'post', action = '' },
          script = { type = 'text/javascript' },
          link = { rel = 'stylesheet', type = 'text/css', href = '' },
          meta = { charset = '${charset}' }
        },
        snippets = {
          html = '<!DOCTYPE html>\n'
            .. '<html lang="${lang}">\n'
            .. '<head>\n'
            .. '\t<meta charset="${charset}">\n'
            .. '\t<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
            .. '\t<title>${title}</title>\n'
            .. '</head>\n'
            .. '<body>\n'
            .. '\t${child}|\n'
            .. '</body>\n'
            .. '</html>',
          ['!!!'] = '<!DOCTYPE html>',
          ['!5'] = '<!DOCTYPE html>',
          ['doc'] = '<!DOCTYPE html>\n<html>\n<head>\n\t<title></title>\n</head>\n<body>\n\t|\n</body>\n</html>'
        }
      },
      
      -- JSX/TSX specific
      javascriptreact = {
        extends = 'jsx',
        default_attributes = {
          div = { className = nil },
          span = { className = nil },
          img = { src = '', alt = '', className = nil },
          input = { type = 'text', className = nil },
          button = { type = 'button', className = nil }
        }
      },
      typescriptreact = {
        extends = 'jsx',
        default_attributes = {
          div = { className = nil },
          span = { className = nil },
          img = { src = '', alt = '', className = nil },
          input = { type = 'text', className = nil },
          button = { type = 'button', className = nil }
        }
      },
      jsx = {
        attribute_name = {
          class = 'className',
          ['for'] = 'htmlFor'
        },
        default_attributes = {
          div = { className = nil },
          span = { className = nil },
          img = { src = '', alt = '', className = nil },
          input = { type = 'text', className = nil },
          button = { type = 'button', className = nil }
        }
      },
      
      -- Vue.js
      vue = {
        extends = 'html',
        default_attributes = {
          div = { class = nil, ['v-if'] = nil },
          span = { class = nil },
          input = { ['v-model'] = nil, type = 'text' },
          button = { ['@click'] = nil, type = 'button' }
        }
      },
      
      -- Svelte
      svelte = {
        extends = 'html',
        default_attributes = {
          div = { class = nil, ['bind:this'] = nil },
          input = { ['bind:value'] = nil, type = 'text' },
          button = { ['on:click'] = nil, type = 'button' }
        }
      },
      
      -- PHP
      php = {
        extends = 'html',
        snippets = {
          php = '<?php ${cursor} ?>',
          echo = '<?= ${cursor} ?>',
          ['if'] = '<?php if (${condition}): ?>\n\t${cursor}\n<?php endif; ?>'
        }
      },
      
      -- CSS and preprocessors
      css = {
        snippets = {
          ['box-sizing'] = 'box-sizing: border-box;',
          ['flex-center'] = 'display: flex;\njustify-content: center;\nalign-items: center;',
          ['grid-center'] = 'display: grid;\nplace-items: center;',
          ['reset'] = '* {\n\tmargin: 0;\n\tpadding: 0;\n\tbox-sizing: border-box;\n}',
          ['container'] = '.container {\n\tmax-width: 1200px;\n\tmargin: 0 auto;\n\tpadding: 0 1rem;\n}'
        }
      },
      
      scss = {
        extends = 'css'
      },
      
      sass = {
        extends = 'css'
      },
      
      less = {
        extends = 'css'
      },
      
      -- XML variants
      xml = {
        default_attributes = {
          ['?xml'] = { version = '1.0', encoding = 'UTF-8' }
        }
      },
      
      svg = {
        extends = 'xml',
        default_attributes = {
          svg = { xmlns = 'http://www.w3.org/2000/svg', viewBox = '0 0 24 24' },
          path = { d = nil, fill = 'currentColor' },
          circle = { cx = nil, cy = nil, r = nil },
          rect = { x = nil, y = nil, width = nil, height = nil }
        }
      }
    }

    -- File types that should have Emmet enabled
    local emmet_filetypes = {
      "html", "xhtml", "xml", "css", "scss", "sass", "less",
      "javascript", "javascriptreact", "typescript", "typescriptreact", "jsx", "tsx",
      "vue", "svelte", "astro", "solid",
      "php", "erb", "ejs", "handlebars", "mustache", "twig", "blade", "jinja", "django",
      "jsp", "asp", "razor", "liquid",
      "markdown", "mdx", "svg", "xaml", "plist"
    }

    -- Enable Emmet for all supported file types
    vim.api.nvim_create_autocmd("FileType", {
      pattern = emmet_filetypes,
      callback = function()
        vim.cmd("EmmetInstall")
        
        -- Set up key mappings for Emmet (only in these file types)
        local opts = { buffer = true, silent = true }
        
        -- Core Emmet functionality
        vim.keymap.set({ "i", "n" }, "<C-y>,", "<plug>(emmet-expand-abbr)", opts)
        vim.keymap.set({ "i", "n" }, "<C-y>;", "<plug>(emmet-expand-word)", opts)
        vim.keymap.set("v", "<C-y>w", "<plug>(emmet-wrap-with-abbreviation)", opts)
        
        -- Navigation
        vim.keymap.set({ "i", "n" }, "<C-y>n", "<plug>(emmet-move-next)", opts)
        vim.keymap.set({ "i", "n" }, "<C-y>N", "<plug>(emmet-move-prev)", opts)
        
        -- Tag manipulation
        vim.keymap.set({ "n", "v" }, "<C-y>d", "<plug>(emmet-balance-tag-outward)", opts)
        vim.keymap.set({ "n", "v" }, "<C-y>D", "<plug>(emmet-balance-tag-inward)", opts)
        vim.keymap.set({ "i", "n" }, "<C-y>/", "<plug>(emmet-toggle-comment)", opts)
        
        -- Update tag
        vim.keymap.set({ "i", "n" }, "<C-y>u", "<plug>(emmet-update-tag)", opts)
        
        -- Remove tag
        vim.keymap.set({ "n" }, "<C-y>k", "<plug>(emmet-remove-tag)", opts)
        
        -- Split/join tag
        vim.keymap.set({ "n" }, "<C-y>j", "<plug>(emmet-split-join-tag)", opts)
        
        -- Merge lines
        vim.keymap.set({ "n" }, "<C-y>m", "<plug>(emmet-merge-lines)", opts)
        
        -- Code pretty
        vim.keymap.set({ "n", "v" }, "<C-y>c", "<plug>(emmet-code-pretty)", opts)
        
        -- Anchors
        vim.keymap.set({ "i", "n" }, "<C-y>a", "<plug>(emmet-anchorize-url)", opts)
        vim.keymap.set({ "i", "n" }, "<C-y>A", "<plug>(emmet-anchorize-summary)", opts)
        
        -- Image size
        vim.keymap.set({ "i", "n" }, "<C-y>i", "<plug>(emmet-image-size)", opts)
        
        -- Additional helpful mappings for specific contexts
        local filetype = vim.bo.filetype
        
        -- JSX/TSX specific mappings
        if filetype == "javascriptreact" or filetype == "typescriptreact" or filetype == "jsx" or filetype == "tsx" then
          -- Quick className shortcut
          vim.keymap.set("i", "<C-y>cn", "className=\"\"<Left>", opts)
        end
        
        -- Vue specific mappings  
        if filetype == "vue" then
          vim.keymap.set("i", "<C-y>vm", "v-model=\"\"<Left>", opts)
          vim.keymap.set("i", "<C-y>vi", "v-if=\"\"<Left>", opts)
          vim.keymap.set("i", "<C-y>vf", "v-for=\"\"<Left>", opts)
        end
        
        -- Svelte specific mappings
        if filetype == "svelte" then
          vim.keymap.set("i", "<C-y>bv", "bind:value=\"\"<Left>", opts)
          vim.keymap.set("i", "<C-y>oc", "on:click=\"\"<Left>", opts)
        end
        
        -- PHP specific mappings
        if filetype == "php" then
          vim.keymap.set("i", "<C-y>pe", "<?= ?><Left><Left><Left>", opts)
          vim.keymap.set("i", "<C-y>pp", "<?php ?><Left><Left><Left>", opts)
        end
      end,
    })
    
    -- Show a message when Emmet is loaded
    vim.api.nvim_create_autocmd("User", {
      pattern = "EmmetInstalled",
      callback = function()
        vim.notify("Emmet loaded for " .. vim.bo.filetype, vim.log.levels.INFO)
      end,
    })
  end,
}
