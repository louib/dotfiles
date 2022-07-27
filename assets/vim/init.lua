local function get_project_name()
  local current_dir = vim.fn.getcwd()

  local last_dir_name = nil
  for dir_name in string.gmatch(current_dir, "//") do
    last_dir_name = dir_name
    print(dir_name)
  end

  return last_dir_name
end

local function set_filetype_options()
  local buffer_number = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(buffer_number, "filetype")

  if filetype == "sh" then
    vim.bo.makeprg = "shellcheck -f gcc %"
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end

  if filetype == "cpp" then
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end

  if filetype == "python" then
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end
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
  if not pcall(require, "formatter") then
    print("formatter is not installed.")
    return
  end
  if not pcall(require, "formatter.util") then
    print("formatter.util is not installed.")
    return
  end

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
  vim.go.omnifunc = "syntaxcomplete#Complete"

  if not pcall(require, "cmp") then
    print("cmp is not installed.")
    return
  end

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
  if not pcall(require, "lspconfig") then
    print("lspconfig is not installed.")
    return
  end

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

local function configure_key_bindings()
  -- See all the available modes here https://github.com/nanotee/nvim-lua-guide#defining-mappings
  -- See all the available options here https://neovim.io/doc/user/map.html#:map-arguments

  -- Window navigation and creation
  vim.api.nvim_set_keymap("n", "<Space>s", "<C-w>s", { silent = true, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>v", "<C-w>v", { silent = true, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>c", "<C-w>c", { silent = true, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>j", "<C-w>j", { silent = true, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>k", "<C-w>k", { silent = true, noremap = true })

  -- Buffer navigation and management
  vim.api.nvim_set_keymap("n", "<Space>w", ":bdelete<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>h", ":bprevious<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>l", ":bnext<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>1", ":bfirst<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>2", ":e #2<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>3", ":e #3<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>4", ":e #4<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>5", ":e #5<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>6", ":e #6<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>7", ":e #7<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>8", ":e #8<Enter>", { silent = false, noremap = true })
  vim.api.nvim_set_keymap("n", "<Space>9", ":e #9<Enter>", { silent = false, noremap = true })

  -- This unsets the "last search pattern" register by hitting return
  -- Credits to https://stackoverflow.com/a/662914
  vim.api.nvim_set_keymap("n", "<CR>", ":noh<CR><CR>", { silent = false, noremap = true })

  vim.api.nvim_set_keymap("", "<C-c>", "\"+y", { silent = false, noremap = false })

  -- Using the 'q' buffer as the quick buffer, with easy re-apply!
  -- Start recording that buffer with `qq`.
  -- Stop recording with `q`.
  -- Apply with space+q !!!
  vim.api.nvim_set_keymap("n", "<Space>q", "@q", { silent = false, noremap = true })
end

local function configure_commenting()
  if not pcall(require, "Comment") then
    print("Comment is not installed.")
    return
  end

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
end

local function configure_global_options()
  -- wo = window options
  -- bo = buffer options
  -- o = global options
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

  -- TODO not sure that this makes sense just yet.
  vim.wo.colorcolumn = "100"

  -- TODO configure vim.o.wildignore ??

  -- the grep related configuration is inspired by
  -- https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
  -- FIXME switch to rg when I installed it in the neovim container.
  -- vim.go.grepprg = "rg --vimgrep"
  -- vim.go.grepformat = "%f:%l:%c:%m"
  vim.go.grepprg = "grep --binary-files=without-match --exclude-dir=target/ --exclude-dir=.git/ -rni"

  -- The shusia, maia and espresso variants exist for the sonokai colorscheme
  -- FIXME how to change the colorscheme variant?
  local colorscheme = "sonokai"
  -- local colorscheme = "everforest"

  pcall(vim.cmd, "colorscheme " .. colorscheme)
end

local function configure_nvim()
  vim.api.nvim_command('syntax on')

  -- Enable filetype detection
  vim.cmd [[
    filetype plugin on
    filetype plugin indent on
  ]]

  -- Calling packloadall is not necessary, because it will be called after
  -- running the init.lua anyway. Leaving here in case we want to load the plugins
  -- earlier in the future.
  -- vim.api.nvim_command('packloadall')
  --

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
      vim.schedule(set_filetype_options)
    end,
  })

  vim.cmd [[
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost [^l]* cwindow
        autocmd QuickFixCmdPost l* lwindow
    augroup END
  ]]

  -- Running spell checking by default on specific text files.
  -- See https://vimtricks.com/p/vimtrick-spell-checking-in-vim/ for
  -- the spell checking shortcuts.
  vim.cmd [[
    autocmd FileType tex :setlocal spell
    autocmd FileType markdown :setlocal spell
  ]]
end

local function configure()
  configure_nvim()
  configure_global_options()
  configure_key_bindings()
  configure_auto_format()
  configure_default_spacing()
  configure_auto_completion()
  configure_commenting()
  configure_status_bar()
  configure_lsp()
end

configure()
