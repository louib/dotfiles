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

local function configure_auto_completion()
  -- Setup nvim-cmp.
  local cmp = require'cmp'

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

local function configure()
  vim.api.nvim_command('syntax on')
  -- Calling packloadall is not necessary, because it will be called after
  -- running the init.lua anyway. Leaving here in case we want to load the plugins
  -- earlier in the future.
  -- vim.api.nvim_command('packloadall')

  -- wo = window options
  -- bo = buffer options
  -- o = global options

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

  -- FIXME this does not work yet.
  -- vim.o.pastetoggle = escape_termcode'<F5>'

  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true

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
end

return {
    configure = configure
}
