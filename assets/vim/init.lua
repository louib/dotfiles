local function get_project_name()
  local current_dir = vim.fn.getcwd()

  local last_dir_name = nil
  for dir_name in string.gmatch(current_dir, "//") do
    last_dir_name = dir_name
    print(dir_name)
  end

  return last_dir_name
end

local function escape_termcode(raw_termcode)
  -- Adjust boolean arguments as needed
  return vim.api.nvim_replace_termcodes(raw_termcode, true, true, true)
end

local function configure_default_spacing()
  -- Default if we did not customize the filetype
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2
  vim.o.expandtab = true
end


local function configure_auto_format()
  -- Utilities for creating configurations
  local formatter_util = require "formatter.util"

  -- Provides the Format and FormatWrite commands
  require('formatter').setup {
    -- All formatter configurations are opt-in
    filetype = {
      cpp = {
        function()
          return {
            exe = "clang-format",
            stdin = true,
          }
        end
      },
      rust = {
        function()
          return {
            exe = "rustfmt",
            stdin = true,
          }
        end
      },
      lua = {
        -- Pick from defaults:
        require('formatter.filetypes.lua').stylua,

        -- ,or define your own:
        function()
          return {
            exe = "stylua",
            args = {
              "--search-parent-directories",
              "--stdin-filepath",
              formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
              "--",
              "-",
            },
            stdin = true,
          }
        end
      }
    }
  }
end


local function configure_auto_completion()
  -- Setup nvim-cmp.
  local cmp = require('cmp')

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  vim.o.completeopt = 'menu,menuone,noselect'
end

local function configure_status_bar()
  if not pcall(require, "lualine") then
    print("lualine is not installed.")
    return
  end

  require('lualine').setup {
    options = {
      -- FIXME what do I need to enable the icons?
      icons_enabled = false,
      theme = 'auto',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = false,
    },
    sections = {
      lualine_a = {
        {
          'mode',
          padding = 2,
        }
      },
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {
        {
          'filename',
          padding = 2,
        },
      },
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    extensions = {}
  }
end

local function configure_lsp()
  local custom_lsp_attach = function(client, buffer_number)
    -- Use LSP as the handler for omnifunc.
    --    See `:help omnifunc` and `:help ins-completion` for more information.
    vim.api.nvim_buf_set_option(buffer_number, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Use LSP as the handler for formatexpr.
    --    See `:help formatexpr` for more information.
    vim.api.nvim_buf_set_option(buffer_number, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

    -- Mappings.
    -- See `:h :map-arguments` for the options available when mapping
    local mapping_options = { noremap=true, silent=true, buffer=buffer_number }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, mapping_options)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, mapping_options)

    vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, mapping_options)

  end

  local lsp_flags = {
      -- This is the default in Nvim 0.7+
      debounce_text_changes = 150,
  }

  local rust_analyzer_features = {}
  -- FIXME the get_project_name() function is still untested, but
  -- could be useful in the future.
  -- if get_project_name() == "project-name" then
  --   rust_analyzer_features = {"allo"}
  -- end

  require('lspconfig').rust_analyzer.setup{
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          features = rust_analyzer_features,
        }
      }
    }
  }

  require('lspconfig').clangd.setup{
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    settings = {
      ["clangd"] = {}
    }
  }

  -- See https://github.com/neovim/nvim-lspconfig#suggested-configuration for
  -- the suggested top-level configuration and https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  -- for a list of all the available language servers.

  -- add sumneko_lua support.
  -- require'lspconfig'.tsserver.setup{}
  -- TODO add eslint support?
  -- add vanilla JS support?
  -- add dockerfile support?
  -- add python support
  -- add bash support (apparently there's a bash language server)
  -- require'lspconfig'.bashls.setup{}
  -- add YAML language server support?
  -- https://github.com/redhat-developer/yaml-language-server
end

local function configure()
  vim.api.nvim_command('syntax on')
  -- Calling packloadall is not necessary, because it will be called after
  -- running the init.lua anyway. Leaving here in case we want to load the plugins
  -- earlier in the future.
  -- vim.api.nvim_command('packloadall')

  -- wo = window options
  -- bo = buffer options
  -- o = global options

  configure_auto_format()
  configure_default_spacing()
  configure_auto_completion()

  vim.o.encoding = 'utf8'

  -- This is for intelligent merging of lines. Will handle comments for example.
  vim.o.formatoptions = 'jcroql'

  -- Make searching case insensitive
  vim.o.ignorecase = true
  -- ... unless the query has capital letters.
  vim.o.smartcase = true

  -- Disabling mainly for security reasons
  vim.o.modeline = false

  -- Always show the status line
  vim.o.laststatus = 2

  -- Do not fold any of the block dy default.
  vim.o.foldlevel = 99

  vim.o.background = 'dark'
  vim.o.termguicolors = true

  vim.o.pastetoggle = '<F5>'

  -- This will render the trailing spaces and the tabs in a visible way.
  vim.o.listchars = 'tab:>-,trail:·'
  vim.o.list = true

  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true

  -- the grep related configuration is inspired by
  -- https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
  -- FIXME switch to rg when I installed it in the neovim container.
  -- vim.go.grepprg = "rg --vimgrep"
  -- vim.go.grepformat = "%f:%l:%c:%m"
  vim.go.grepprg = "grep --binary-files=without-match --exclude-dir=target/ --exclude-dir=.git/ -rni"
  -- vim.go.grepformat = "%f:%l:%c:%m"

  -- The shusia, maia and espresso variants exist for the sonokai colorscheme
  -- FIXME how to change the colorscheme variant?
  local colorscheme = "sonokai"
  -- local colorscheme = "everforest"

  pcall(vim.cmd, "colorscheme " .. colorscheme)

  -- See https://github.com/numToStr/Comment.nvim#configuration-optional
  require('Comment').setup({
    padding = true,

    ---LHS of operator-pending mappings in NORMAL + VISUAL mode
    ---@type table
    opleader = {
      ---Line-comment keymap
      line = 'gc',
      ---Block-comment keymap
      block = 'gb',
    },
  })

  configure_status_bar()
  configure_lsp()
end

return {
  configure = configure
}
