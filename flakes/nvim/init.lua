local LSP_ENABLED_VAR_NAME = 'LSP_ENABLED'
local COPILOT_ENABLED_VAR_NAME = 'COPILOT_ENABLED'
local ENABLED_FORMATTING_TOOL_VAR_NAME = 'ENABLED_FORMATTING_TOOL'
local ENABLED_LINTING_TOOL_VAR_NAME = 'ENABLED_LINTING_TOOL'
local COPILOT_AI_MODEL_VAR_NAME = 'NVIM_COPILOT_AI_MODEL'
local CURRENT_LANG_VAR_NAME = 'CURRENT_LANG'
local DEFAULT_LANG = 'en_us'
local DEFAULT_COPILOT_AI_MODEL = 'claude-3.5-sonnet'

-- Table to store the current state of auto-formatting
-- for a filetype
local AUTO_FORMATTING_ENABLED = {
  cpp = false,
  c = false,
  yaml = false,
  json = false,
  nix = true,
  javascript = true,
  typescript = true,
  lua = true,
  rust = true,
  python = true,
  go = true,
}

local function get_copilot_ai_model()
  return os.getenv(COPILOT_AI_MODEL_VAR_NAME) or DEFAULT_COPILOT_AI_MODEL
end

local function executable_is_available(executable_name)
  local handle = io.popen(string.format('which %s 2> /dev/null', executable_name))
  if not handle then
    return false
  end

  local output = handle:read('*a')
  handle:close()

  if string.find(output, executable_name) then
    return true
  end

  return false
end

local function get_prettier_formatting_config()
  if not pcall(require, 'formatter.util') then
    return {}
  end

  -- Utilities for creating configurations
  local formatter_util = require('formatter.util')

  local buffer_number = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', {
    buf = buffer_number,
  })
  if AUTO_FORMATTING_ENABLED[filetype] == false then
    return nil
  end

  if executable_is_available('prettier') then
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'prettier')

    -- I do not install prettier on my host machines, which means that if prettier is installed,
    -- I should probably be using it.
    return {
      exe = 'prettier',
      args = {
        '--stdin-filepath',
        formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
      },
      stdin = true,
    }
  end

  -- TODO about tslint
  return {}
end

local function get_terraform_formatting_config()
  if not pcall(require, 'formatter.util') then
    return {}
  end

  -- Utilities for creating configurations
  local formatter_util = require('formatter.util')

  if not executable_is_available('terraform') then
    return {}
  end

  local buffer_number = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'terraform fmt')

  return {
    exe = 'terraform',
    args = {
      'fmt',
      '-write=true',
      '-',
      formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
    },
    stdin = true,
  }
end

local function get_project_name()
  local current_dir = vim.fn.getcwd()

  local last_dir_name = nil
  for dir_name in string.gmatch(current_dir, '//') do
    last_dir_name = dir_name
    print(dir_name)
  end

  return last_dir_name
end

local function prepare_embedded_buffer()
  local buffer_number = vim.api.nvim_get_current_buf()

  -- See the buftype option for details
  -- https://neovim.io/doc/user/options.html#'buftype'
  vim.api.nvim_set_option_value('buftype', 'nofile', {
    buf = buffer_number,
  })
  vim.api.nvim_set_option_value('filetype', 'markdown', {
    buf = buffer_number,
  })
end

local function set_filetype_options()
  local buffer_number = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', {
    buf = buffer_number,
  })
  -- Apparently this is the only way to get the path associated with a buffer.
  local buffer_path = vim.api.nvim_buf_get_name(buffer_number)

  -- Default if we cannot detect the filetype.
  vim.wo.spell = false
  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
  vim.bo.expandtab = true
  vim.bo.makeprg = 'echo "Make is disabled for this filetype."'

  -- TODO not sure that this makes sense just yet.
  vim.wo.colorcolumn = '100'

  -- This is mainly to prevent netrw (the directory browser) from always keeping the
  -- buffer hidden. This makes it difficult to close it.
  vim.go.hidden = false

  if filetype == 'typescript' or filetype == 'javascript' or filetype == 'yaml' or filetype == 'json' then
    -- We call this function here because is has the side-effect of detecting which formatting
    -- tools are available at this time.
    get_prettier_formatting_config()
  end

  if filetype == 'sh' then
    vim.bo.makeprg = 'shellcheck -f gcc %'
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_LINTING_TOOL_VAR_NAME, 'shellcheck')
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    return
  end

  if filetype == 'rust' then
    vim.bo.makeprg = 'cargo build -q --message-format short'
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_LINTING_TOOL_VAR_NAME, 'cargo')
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'rustfmt')
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    return
  end

  if filetype == 'lua' then
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'stylua')
    return
  end

  if filetype == 'go' then
    vim.bo.tabstop = 8 -- Go standard is 8-space tabs
    vim.bo.shiftwidth = 8
    -- Go convention requires tabs for indentation
    vim.bo.expandtab = false
    vim.bo.makeprg = 'go build -v ./%'
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_LINTING_TOOL_VAR_NAME, 'go vet')
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'gofmt')
    vim.bo.errorformat = '%f:%l:%c: %m'
    return
  end

  if filetype == 'make' then
    vim.bo.expandtab = false
    return
  end

  if filetype == 'nix' then
    -- see :help filename-modifiers
    -- :p means the full path
    -- :h means the head (last component) removed.
    -- nix check flake requires the directory in which the flake resides, not the
    -- path to the flake itself.
    if string.match(buffer_path, 'flake.nix') then
      vim.bo.makeprg = 'nix flake check %:p:h'
      vim.api.nvim_buf_set_var(buffer_number, ENABLED_LINTING_TOOL_VAR_NAME, 'nix flake check')
    end
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'alejandra')
    return
  end

  if filetype == 'cpp' then
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'clang-format')
    return
  end

  if filetype == 'python' then
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'ruff')
    return
  end

  if filetype == 'terraform' then
    -- We call this function here because is has the side-effect of detecting which formatting
    -- tools are available at this time.
    get_terraform_formatting_config()
    return
  end

  if filetype == 'gitcommit' then
    vim.wo.colorcolumn = '72'
    return
  end

  if filetype == 'xml' then
    -- vim.g['xml_syntax_folding'] = 1
    -- TODO syntax folding would be better, but for that I would need an XML syntax
    -- file.
    vim.wo.foldmethod = 'indent'
    vim.wo.foldnestmax = 1
    vim.wo.foldminlines = 0
    return
  end

  if filetype == 'yaml' then
    if string.match(buffer_path, '.github/workflows/') then
      vim.bo.makeprg = 'actionlint -oneline -shellcheck shellcheck %'
      vim.bo.errorformat = '%f:%l:%c: %m'
      vim.api.nvim_buf_set_var(buffer_number, ENABLED_LINTING_TOOL_VAR_NAME, 'actionlint')
      return
    end
  end

  -- Running spell checking by default on specific text files.
  -- See https://vimtricks.com/p/vimtrick-spell-checking-in-vim/ for
  -- the spell checking shortcuts.
  if filetype == 'tex' then
    vim.wo.spell = true
    return
  end
  if filetype == 'markdown' then
    vim.bo.makeprg = 'markdownlint %'
    vim.bo.errorformat = '%f:%l %m'

    vim.api.nvim_buf_set_var(buffer_number, ENABLED_LINTING_TOOL_VAR_NAME, 'markdownlint')

    -- FIXME not sure that both are needed
    vim.wo.spell = true
    vim.opt.spell = true

    vim.api.nvim_buf_set_var(buffer_number, CURRENT_LANG_VAR_NAME, DEFAULT_LANG)
    vim.opt.spelllang = { DEFAULT_LANG }
    return
  end
end

local function formatting_is_enabled()
  if os.getenv('NVIM_DISABLE_FORMATTING') == 'true' then
    return false
  end
  return true
end

local function configure_auto_format()
  if not pcall(require, 'formatter') then
    print('formatter is not installed.')
    return
  end
  if not pcall(require, 'formatter.util') then
    print('formatter.util is not installed.')
    return
  end

  if not formatting_is_enabled() then
    return
  end

  -- Utilities for creating configurations
  local formatter_util = require('formatter.util')

  local get_cpp_config = function()
    if AUTO_FORMATTING_ENABLED['cpp'] == false then
      return nil
    end

    return {
      exe = 'clang-format',
      stdin = true,
    }
  end

  local get_nix_config = function()
    if AUTO_FORMATTING_ENABLED['nix'] == false then
      return nil
    end

    return {
      exe = 'alejandra',
      stdin = true,
      args = {
        '-q',
        '-',
      },
    }
  end

  local get_rust_config = function()
    if AUTO_FORMATTING_ENABLED['rust'] == false then
      return nil
    end

    return {
      exe = 'rustfmt',
      stdin = true,
    }
  end

  local get_lua_config = function()
    if AUTO_FORMATTING_ENABLED['lua'] == false then
      return nil
    end

    return {
      exe = 'stylua',
      args = {
        '--search-parent-directories',
        '--stdin-filepath',
        formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
        '--',
        '-',
      },
      stdin = true,
    }
  end

  local get_python_config = function()
    if AUTO_FORMATTING_ENABLED['python'] == false then
      return nil
    end

    return {
      exe = 'ruff',
      args = {
        'format',
        '--stdin-filename',
        formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
        '-',
      },
      stdin = true,
    }
  end

  local get_go_config = function()
    if AUTO_FORMATTING_ENABLED['go'] == false then
      return nil
    end

    local buffer_number = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_var(buffer_number, ENABLED_FORMATTING_TOOL_VAR_NAME, 'gofmt')

    return {
      exe = 'gofmt',
      stdin = true,
    }
  end

  -- Provides the Format and FormatWrite commands
  -- See https://github.com/mhartington/formatter.nvim#configuration-specification
  -- for all the configuration options.
  require('formatter').setup({
    -- Enable or disable logging
    logging = false,
    -- Set the log level
    log_level = vim.log.levels.WARN,

    -- All formatter configurations are opt-in
    filetype = {
      cpp = {
        get_cpp_config,
      },
      rust = {
        get_rust_config,
      },
      nix = {
        get_nix_config,
      },
      lua = {
        get_lua_config,
      },
      python = {
        get_python_config,
      },
      go = {
        get_go_config,
      },
      javascript = {
        get_prettier_formatting_config,
      },
      typescript = {
        get_prettier_formatting_config,
      },
      yaml = {
        get_prettier_formatting_config,
      },
      terraform = {
        get_terraform_formatting_config,
      },
    },
  })

  -- this will format and write the buffer after saving.
  vim.cmd([[
    augroup FormatAutogroup
      autocmd!
      autocmd BufWritePost * FormatWrite
    augroup END
  ]])

  vim.keymap.set('n', '<Space>f', function()
    local buffer_number = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_get_option_value('filetype', {
      buf = buffer_number,
    })

    if not AUTO_FORMATTING_ENABLED[filetype] then
      AUTO_FORMATTING_ENABLED[filetype] = true
    else
      AUTO_FORMATTING_ENABLED[filetype] = false
    end

    require('lualine').refresh()
  end, { silent = true })
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local function configure_auto_completion()
  vim.go.omnifunc = 'syntaxcomplete#Complete'

  if os.getenv('NVIM_DISABLE_AUTO_COMPLETION') == 'true' then
    return false
  end

  if not pcall(require, 'cmp') then
    print('cmp is not installed.')
    return
  end

  -- Setup nvim-cmp.
  local cmp = require('cmp')

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
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
      ['<C-k>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.fn['vsnip#jumpable'](-1) == 1 then
          feedkey('<Plug>(vsnip-jump-prev)', '')
        end
      end, { 'i', 's' }),
      ['<C-j>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_next_item()
        end
      end, { 'i', 's' }),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      -- Require Tab to accept a suggestion without confirmation, but Enter to
      -- accept if explicitely selected.
      ['<Tab>'] = cmp.mapping.confirm({ select = true }),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
      {
        name = 'dictionary',
        keyword_length = 2,
      },
      {
        name = 'emoji',
      },
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'copilot', group_index = 2 },
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
      {
        name = 'spell',
        option = {
          keep_all_entries = true,
          enable_in_context = function()
            return true
          end,
          preselect_correct_word = true,
        },
      },
    }, {
      { name = 'buffer' },
    }, {
      -- This uses cmp-path
      -- See https://github.com/hrsh7th/cmp-path#configuration for details
      -- on how to configure.
      { name = 'path' },
    }),
  })

  -- Set configuration for specific filetype.
  ---@diagnostic disable-next-line: undefined-field
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    }),
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  ---@diagnostic disable-next-line: undefined-field
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })

  -- Commenting out this one for the moment since it breaks using the '%' as a shorthand
  -- for the current buffer file path
  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  ---@diagnostic disable-next-line: undefined-field
  cmp.setup.cmdline(':', {
    -- Default mappings are defined here:
    -- https://github.com/hrsh7th/nvim-cmp/blob/0b751f6beef40fd47375eaf53d3057e0bfa317e4/lua/cmp/config/mapping.lua#L74
    mapping = cmp.mapping.preset.cmdline({
      ['<C-j>'] = {
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end,
      },
      ['<C-k>'] = {
        c = function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end,
      },
      ['<Tab>'] = {
        c = function()
          if cmp.visible() then
            cmp.confirm({ select = true })
          else
            cmp.complete()
          end
        end,
      },
    }),
    sources = cmp.config.sources({
      { name = 'cmdline' },
    }, {
      { name = 'path' },
    }),
  })

  -- vim.o.completeopt = 'menu,menuone,noselect'
  vim.o.completeopt = 'menu,menuone,noselect,preview'

  local dictionaries = {}
  local en_db_path = os.getenv('NVIM_DICTDB_EN_PATH')
  if en_db_path and en_db_path ~= '' then
    dictionaries.add(en_db_path)
  end
  local fr_db_path = os.getenv('NVIM_DICTDB_FR_PATH')
  if fr_db_path and fr_db_path ~= '' then
    dictionaries.add(fr_db_path)
  end

  require('cmp_dictionary').setup({
    paths = dictionaries,
    exact_length = 2,
    first_case_insensitive = true,
    document = {
      enable = true,
      command = { 'wn', '${label}', '-over' },
    },
  })
end

local function configure_status_bar()
  if not pcall(require, 'lualine') then
    print('lualine is not installed.')
    return
  end

  local function get_embedded_buffer_name()
    return os.getenv('NVIM_EMBEDDED_BUFFER_NAME') or 'No Name'
  end

  local filename_section = os.getenv('NVIM_EMBEDDED') == 'true' and get_embedded_buffer_name
    or {
      'filename',
      -- 0: Just the filename
      -- 1: Relative path
      -- 2: Absolute path
      -- 3: Absolute path, with tilde as the home directory
      path = 1,
      padding = 1,
    }

  -- https://github.com/nvim-lualine/lualine.nvim#available-components
  -- for the available components.
  require('lualine').setup({
    options = {
      -- FIXME what do I need to enable the icons?
      icons_enabled = false,
      theme = {
        normal = {
          a = { fg = '#282828', bg = '#458588', gui = 'bold' },
          b = { fg = '#ebdbb2', bg = '#504945' },
          c = { fg = '#ebdbb2', bg = '#3c3836' },
        },
        insert = {
          a = { fg = '#282828', bg = '#8ec07c', gui = 'bold' },
          b = { fg = '#ebdbb2', bg = '#504945' },
          c = { fg = '#ebdbb2', bg = '#3c3836' },
        },
        visual = {
          a = { fg = '#282828', bg = '#b16286', gui = 'bold' },
          b = { fg = '#ebdbb2', bg = '#504945' },
          c = { fg = '#ebdbb2', bg = '#3c3836' },
        },
        replace = {
          a = { fg = '#282828', bg = '#cc241d', gui = 'bold' },
          b = { fg = '#ebdbb2', bg = '#504945' },
          c = { fg = '#ebdbb2', bg = '#3c3836' },
        },
        command = {
          a = { fg = '#282828', bg = '#d65d0e', gui = 'bold' },
          b = { fg = '#ebdbb2', bg = '#504945' },
          c = { fg = '#ebdbb2', bg = '#3c3836' },
        },
        inactive = {
          a = { fg = '#ebdbb2', bg = '#3c3836', gui = 'bold' },
          b = { fg = '#ebdbb2', bg = '#3c3836' },
          c = { fg = '#ebdbb2', bg = '#3c3836' },
        },
      },
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = false,
    },
    sections = {
      lualine_a = {
        {
          'mode',
          padding = 1,
        },
      },
      lualine_b = {
        {
          'branch',
          padding = 1,
        },
        {
          'diff',
          padding = 1,
        },
        {
          'diagnostics',
          padding = 1,
        },
      },
      lualine_c = {
        filename_section,
      },
      lualine_x = {
        {
          function()
            local tools = ''

            local formatter_enabled, formatter_tool_name =
              pcall(vim.api.nvim_buf_get_var, 0, ENABLED_FORMATTING_TOOL_VAR_NAME)
            if formatter_enabled and formatter_tool_name then
              -- Put the autoformat first so that we don't shift the other tools when toggling it.
              local buffer_number = vim.api.nvim_get_current_buf()
              local filetype = vim.api.nvim_get_option_value('filetype', {
                buf = buffer_number,
              })
              local auto_formatting_enabled = AUTO_FORMATTING_ENABLED[filetype]
              if auto_formatting_enabled ~= false then
                tools = tools .. '(autoformat)'
              end

              tools = tools .. '(' .. formatter_tool_name .. ')'
            end

            local nix_shell_var = os.getenv('IN_NIX_SHELL')
            if nix_shell_var and nix_shell_var:gsub('^%s*(.-)%s*$', '%1') ~= '' then
              tools = tools .. '(nix)'
            end

            local copilot_enabled, copilot_response = pcall(vim.api.nvim_buf_get_var, 0, COPILOT_ENABLED_VAR_NAME)
            if copilot_enabled and copilot_response then
              if pcall(require, 'CopilotChat') then
                local chat_config = require('CopilotChat').config
                tools = tools .. string.format('(copilot using %s)', chat_config.model)
              else
                tools = tools .. '(copilot)'
                return
              end
            end

            local lsp_enabled, lsp_tool_name = pcall(vim.api.nvim_buf_get_var, 0, LSP_ENABLED_VAR_NAME)
            if lsp_enabled and lsp_tool_name then
              tools = tools .. '(lsp)'
            end

            local linter_enabled, linter_tool_name = pcall(vim.api.nvim_buf_get_var, 0, ENABLED_LINTING_TOOL_VAR_NAME)
            if linter_enabled and linter_tool_name then
              tools = tools .. '(' .. linter_tool_name .. ')'
            end

            -- TODO add an emoji to indicate errors when configuring the tools.

            local spellcheck_enabled, spellcheck_lang = pcall(vim.api.nvim_buf_get_var, 0, CURRENT_LANG_VAR_NAME)
            if spellcheck_enabled and spellcheck_lang then
              tools = tools .. '(' .. spellcheck_lang .. ')'
            end

            return tools
          end,
          padding = 1,
        },
      },
      lualine_y = {
        'progress',
      },
      lualine_z = {
        {
          function()
            -- local current_buffer = vim.api.nvim_get_current_buf()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local _, column = unpack(cursor)
            -- The column returned by the vim API starts at 0,
            -- so we increment it here.
            return string.format('%s', column + 1)
          end,
          padding = 1,
        },
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          'filename',
          -- 0: Just the filename
          -- 1: Relative path
          -- 2: Absolute path
          -- 3: Absolute path, with tilde as the home directory
          path = 1,
          padding = 1,
        },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {
      lualine_a = {
        {
          'buffers',
          show_modified_status = true,

          -- 0: Shows buffer name
          -- 1: Shows buffer index
          -- 2: Shows buffer name + buffer index
          -- 3: Shows buffer number
          -- 4: Shows buffer name + buffer number
          mode = 2,

          max_length = vim.o.columns,

          symbols = {
            -- Text to show when the buffer is modified
            modified = ' ●',
            -- Text to show to identify the alternate file
            alternate_file = '',
            -- Text to show when the buffer is a directory
            directory = '📁',
          },
        },
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = {},
  })

  vim.api.nvim_set_keymap('n', '<Space>1', ':LualineBuffersJump 1<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>2', ':LualineBuffersJump 2<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>3', ':LualineBuffersJump 3<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>4', ':LualineBuffersJump 4<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>5', ':LualineBuffersJump 5<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>6', ':LualineBuffersJump 6<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>7', ':LualineBuffersJump 7<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>8', ':LualineBuffersJump 8<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>9', ':LualineBuffersJump 9<Enter>', { silent = false, noremap = true })
end

local function configure_lastplace()
  if not pcall(require, 'nvim-lastplace') then
    print('nvim-lastplace is not installed.')
    return
  end

  -- Currently using the default settings. See
  -- https://github.com/ethanholz/nvim-lastplace#installation
  require('nvim-lastplace').setup({
    lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help' },
    lastplace_ignore_filetype = { 'gitcommit', 'gitrebase', 'svn', 'hgcommit' },
    lastplace_open_folds = true,
  })
end

local function configure_lsp()
  if not pcall(require, 'lspconfig') then
    print('lspconfig is not installed.')
    return
  end

  local custom_lsp_attach = function(client, buffer_number)
    -- Use LSP as the handler for omnifunc.
    --    See `:help omnifunc` and `:help ins-completion` for more information.
    vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', {
      buf = buffer_number,
    })

    -- Use LSP as the handler for formatexpr.
    --    See `:help formatexpr` for more information.
    vim.api.nvim_set_option_value('formatexpr', 'v:lua.vim.lsp.formatexpr()', {
      buf = buffer_number,
    })

    -- Mappings.
    -- See `:h :map-arguments` for the options available when mapping
    local mapping_options = { noremap = true, silent = true, buffer = buffer_number }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, mapping_options)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, mapping_options)

    vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, mapping_options)

    vim.api.nvim_buf_set_var(buffer_number, LSP_ENABLED_VAR_NAME, true)
  end

  local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
  }

  require('lspconfig').rust_analyzer.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
        },
      },
    },
  })

  -- Documented at https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
  require('lspconfig').lua_ls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file('', true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })

  -- Documented at https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
  require('lspconfig').ts_ls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
  })

  -- Documented at https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#nil_ls
  require('lspconfig').nil_ls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    settings = {
      ['nil'] = {
        nix = {
          flake = {
            autoArchive = false,
          },
        },
      },
    },
  })

  require('lspconfig').clangd.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    settings = {
      ['clangd'] = {},
    },
  })

  require('lspconfig').jsonls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
  })

  require('lspconfig').taplo.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
  })

  require('lspconfig').dockerls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
  })

  require('lspconfig').gopls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  })

  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
  require('lspconfig').yamlls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
    settings = {
      ['yaml'] = {
        -- Name has to be in camelCase because this is what the yaml-language-server uses.
        keyOrdering = false,
        redhat = {
          telemetry = {
            enabled = false,
          },
        },
      },
    },
  })

  require('lspconfig').bashls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
  })

  -- Other option for terraform is terraform-lsp:
  -- ```
  -- require('lspconfig').terraform_lsp.setup({})
  -- ```
  require('lspconfig').terraformls.setup({
    on_attach = custom_lsp_attach,
    flags = lsp_flags,
  })

  -- See https://github.com/neovim/nvim-lspconfig#suggested-configuration for
  -- the suggested top-level configuration and https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  -- for a list of all the available language servers.

  -- TODO add sumneko_lua support.
  -- TODO add eslint support?
  -- TODO add vanilla JS support?
  -- TODO add dockerfile support?
  -- TODO add python support
end

local function configure_key_bindings()
  -- See all the available modes here https://github.com/nanotee/nvim-lua-guide#defining-mappings
  -- See all the available options here https://neovim.io/doc/user/map.html#:map-arguments

  -- Window navigation and creation
  -- I no longer support vertical splits, only horizontal splits.
  vim.api.nvim_set_keymap('n', '<Space>s', '<C-w>s', { silent = true, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>c', '<C-w>c', { silent = true, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>j', '<C-w>j', { silent = true, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>k', '<C-w>k', { silent = true, noremap = true })

  -- Buffer management
  -- Buffer navigation is now handled by lualine.
  vim.api.nvim_set_keymap('n', '<Space>d', ':bdelete<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>h', ':bprevious<Enter>', { silent = false, noremap = true })
  vim.api.nvim_set_keymap('n', '<Space>l', ':bnext<Enter>', { silent = false, noremap = true })

  -- This unsets the "last search pattern" register by hitting return
  -- Credits to https://stackoverflow.com/a/662914
  vim.api.nvim_set_keymap('n', '<CR>', ':noh<CR><CR>', { silent = false, noremap = true })

  vim.api.nvim_set_keymap('', '<C-c>', '"+y', { silent = false, noremap = false })

  -- Using the 'q' buffer as the quick buffer, with easy re-apply!
  -- Start recording that buffer with `qq`.
  -- Stop recording with `q`.
  -- Apply with space+q !!!
  vim.api.nvim_set_keymap('n', '<Space>q', '@q', { silent = false, noremap = true })

  -- When in terminal mode, I don't want to remap Esc to exit, because the terminal
  -- line cannot be modified from the nvim buffer. I might want to use the vi mode from bash
  -- to edit the line by pressing Esc instead.
  vim.api.nvim_set_keymap('t', '<Space><Esc>', '<C-\\><C-n>', { silent = false, noremap = true })

  vim.api.nvim_set_keymap('n', '<C-n>', ':CopilotChatOpen<Enter>', { silent = false, noremap = true })

  vim.api.nvim_set_keymap('n', '<C-b>', ':GitBlameCopyFileURL<Enter>', { silent = false, noremap = true })

  -- Copy current buffer path to clipboard
  vim.api.nvim_set_keymap(
    'n',
    '<Space>y',
    [[:let @+ = expand('%:p')<CR>:echo "Copied: " . expand('%:p')<CR>]],
    { silent = false, noremap = true }
  )

  if os.getenv('NVIM_EMBEDDED') == 'true' then
    local embedded_exit_sequence = 'w >> /dev/stderr<Enter>:q!<Enter>'
    vim.api.nvim_set_keymap('c', 'w<Enter>', embedded_exit_sequence, { silent = false, noremap = true })
    vim.api.nvim_set_keymap('c', 'wq<Enter>', embedded_exit_sequence, { silent = false, noremap = true })
  end
end

local function configure_commenting()
  -- I'm having issues with comment.nvim, So I'm currently trying comment_nvim instead.
  if os.getenv('NVIM_ENABLE_COMMENT_NVIM') == 'true' then
    if not pcall(require, 'nvim_comment') then
      print('nvim_comment is not installed.')
      return
    end

    -- Config options are documented here
    -- https://github.com/terrortylor/nvim-comment?tab=readme-ov-file#configure
    require('nvim_comment').setup({
      -- should comment out empty or whitespace only lines
      comment_empty = false,

      -- Should key mappings be created
      create_mappings = true,

      -- Normal mode mapping left hand side
      line_mapping = 'gcc',

      -- Visual/Operator mapping left hand side
      operator_mapping = 'gc',
    })
  else
    if not pcall(require, 'Comment') then
      print('Comment is not installed.')
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
end

-- Define our custom theme with environment variable loading
local my_custom_theme = {}

-- Function to check if environment variables for colors are set
local function should_use_custom_colors()
  -- Check for at least one color environment variable to determine if we should use custom colors
  local required_env_vars = { 'NVIM_COLOR_ENABLED' }
  for _, env_name in ipairs(required_env_vars) do
    local env_value = os.getenv(env_name)
    if env_value and env_value:lower() == 'true' then
      return true
    end
  end
  return false
end

-- Function to get color from environment variable
local function get_color(color_name)
  local env_name = 'NVIM_COLOR_' .. color_name:upper():gsub('%-', '_')
  local env_value = os.getenv(env_name)
  if env_value and env_value ~= '' then
    -- Add # prefix if not present
    if env_value:sub(1, 1) ~= '#' then
      env_value = '#' .. env_value
    end
    return env_value
  end
  return nil
end

-- Initialize the palette
local palette = {}

if should_use_custom_colors() then
  -- Get all environment variables
  local environ = vim.fn.environ()

  -- Look for all NVIM_COLOR_ variables and add them to the palette
  for name, value in pairs(environ) do
    local color_key = name:match("^NVIM_COLOR_(.+)$")
    if color_key and color_key ~= "ENABLED" then
      -- Convert to lowercase
      color_key = color_key:lower()

      -- Add # prefix if not present
      if value:sub(1, 1) ~= "#" then
        value = "#" .. value
      end

      -- Add to palette
      palette[color_key] = value
    end
  end
end

function my_custom_theme.setup()
  -- Check if environment variable is set to enable custom colors
  if not should_use_custom_colors() then
    return nil
  end

  -- Check if we have enough colors to build a theme
  local essential_colors = { "dark0", "dark1", "light1" }
  for _, color in ipairs(essential_colors) do
    if not palette[color] then
      print('Not applying custom theme: missing essential color ' .. color)
      return nil
    end
  end

  -- Check if we have at least some basic color definitions
  if vim.tbl_count(palette) < 5 then
    print('Not applying custom theme: not enough colors defined')
    return nil
  end

  local color_groups = {
    dark = {
      bg0 = palette.dark0,
      bg1 = palette.dark1,
      bg2 = palette.dark2,
      bg3 = palette.dark3,
      bg4 = palette.dark4,
      fg0 = palette.light0,
      fg1 = palette.light1,
      fg2 = palette.light2,
      fg3 = palette.light3,
      fg4 = palette.light4,
      red = palette.bright_red,
      green = palette.bright_green,
      yellow = palette.bright_yellow,
      blue = palette.bright_blue,
      purple = palette.bright_purple,
      aqua = palette.bright_aqua,
      orange = palette.bright_orange,
      neutral_red = palette.neutral_red,
      neutral_green = palette.neutral_green,
      neutral_yellow = palette.neutral_yellow,
      neutral_blue = palette.neutral_blue,
      neutral_purple = palette.neutral_purple,
      neutral_aqua = palette.neutral_aqua,
      dark_red = palette.faded_red,
      dark_green = palette.faded_green,
      dark_aqua = palette.faded_aqua,
      gray = palette.gray,
    },
    light = {
      bg0 = palette.light0,
      bg1 = palette.light1,
      bg2 = palette.light2,
      bg3 = palette.light3,
      bg4 = palette.light4,
      fg0 = palette.dark0,
      fg1 = palette.dark1,
      fg2 = palette.dark2,
      fg3 = palette.dark3,
      fg4 = palette.dark4,
      red = palette.faded_red,
      green = palette.faded_green,
      yellow = palette.faded_yellow,
      blue = palette.faded_blue,
      purple = palette.faded_purple,
      aqua = palette.faded_aqua,
      orange = palette.faded_orange,
      neutral_red = palette.neutral_red,
      neutral_green = palette.neutral_green,
      neutral_yellow = palette.neutral_yellow,
      neutral_blue = palette.neutral_blue,
      neutral_purple = palette.neutral_purple,
      neutral_aqua = palette.neutral_aqua,
      dark_red = palette.light_red,
      dark_green = palette.light_green,
      dark_aqua = palette.light_aqua,
      gray = palette.gray,
    },
  }

  -- Use dark mode colors
  local c = color_groups.dark

  -- Define highlight groups
  local groups = {
    -- Base highlights
    Normal = { fg = c.fg1, bg = c.bg0 },
    NormalFloat = { fg = c.fg1, bg = c.bg1 },
    Bold = { bold = true },
    Italic = { italic = true },
    Underlined = { underline = true, fg = c.fg1 },
    Cursor = { bg = c.fg1 },
    CursorLine = { bg = c.bg1 },
    CursorColumn = { bg = c.bg1 },
    ColorColumn = { bg = c.bg1 },
    LineNr = { fg = c.bg4 },
    CursorLineNr = { fg = c.yellow },
    Visual = { bg = c.bg2 },
    VisualNOS = { bg = c.bg2 },
    Search = { fg = c.bg0, bg = c.yellow },
    IncSearch = { fg = c.bg0, bg = c.orange },

    -- Syntax highlighting
    Comment = { fg = c.gray, italic = true },
    SpecialComment = { fg = c.gray, italic = true },
    Constant = { fg = c.purple },
    String = { fg = c.green },
    Character = { fg = c.purple },
    Number = { fg = c.purple },
    Boolean = { fg = c.purple },
    Float = { fg = c.purple },
    Identifier = { fg = c.blue },
    Function = { fg = c.aqua },
    Statement = { fg = c.red },
    Conditional = { fg = c.red },
    Repeat = { fg = c.red },
    Label = { fg = c.red },
    Operator = { fg = c.red },
    Keyword = { fg = c.red },
    Exception = { fg = c.red },
    PreProc = { fg = c.aqua },
    Include = { fg = c.aqua },
    Define = { fg = c.aqua },
    Macro = { fg = c.aqua },
    PreCondit = { fg = c.aqua },
    Type = { fg = c.yellow },
    StorageClass = { fg = c.orange },
    Structure = { fg = c.aqua },
    Typedef = { fg = c.yellow },
    Special = { fg = c.orange },
    SpecialChar = { fg = c.red },
    Tag = { fg = c.aqua },
    Delimiter = { fg = c.fg3 },

    -- UI elements
    StatusLine = { fg = '#ebdbb2', bg = '#504945' },
    StatusLineNC = { fg = c.fg4, bg = c.bg1 },
    TabLine = { fg = c.fg3, bg = c.bg2 },
    TabLineFill = { fg = c.fg4, bg = c.bg1 },
    TabLineSel = { fg = '#282828', bg = '#458588' },
    VertSplit = { fg = c.bg2 },
    Folded = { fg = c.gray, bg = c.bg1 },
    FoldColumn = { fg = c.gray, bg = c.bg0 },
    SignColumn = { fg = c.fg1, bg = c.bg0 },
    NonText = { fg = c.bg3 },
    SpecialKey = { fg = c.bg3 },
    Pmenu = { fg = c.fg1, bg = c.bg2 },
    PmenuSel = { fg = c.bg0, bg = c.blue },
    PmenuSbar = { bg = c.bg2 },
    PmenuThumb = { bg = c.bg4 },
    WildMenu = { fg = c.blue, bg = c.bg2, bold = true },
    Title = { fg = c.green, bold = true },
    Directory = { fg = c.blue },

    -- Messages
    Error = { fg = c.red },
    ErrorMsg = { fg = c.red },
    WarningMsg = { fg = c.yellow },
    MoreMsg = { fg = c.blue },
    Question = { fg = c.orange },

    -- Diagnostics
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.aqua },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.aqua },

    -- Diff
    DiffAdd = { bg = c.dark_green },
    DiffChange = { bg = c.dark_aqua },
    DiffDelete = { bg = c.dark_red },
    DiffText = { bg = c.neutral_blue },

    -- Spell checking
    SpellBad = { undercurl = true, sp = c.red },
    SpellCap = { undercurl = true, sp = c.blue },
    SpellRare = { undercurl = true, sp = c.purple },
    SpellLocal = { undercurl = true, sp = c.aqua },

    -- Treesitter specific
    ['@keyword'] = { fg = c.red },
    ['@string'] = { fg = c.green },
    ['@function'] = { fg = c.aqua },
    ['@function.builtin'] = { fg = c.orange },
    ['@variable'] = { fg = c.fg1 },
    ['@field'] = { fg = c.blue },
    ['@property'] = { fg = c.blue },
    ['@parameter'] = { fg = c.fg3 },

    -- LSP
    LspReferenceText = { bg = c.bg2 },
    LspReferenceRead = { bg = c.bg2 },
    LspReferenceWrite = { bg = c.bg2 },

    -- For Lualine
    LualineModeNormal = { fg = '#282828', bg = '#458588', bold = true },
    LualineModeInsert = { fg = '#282828', bg = '#8ec07c', bold = true },
    LualineModeVisual = { fg = '#282828', bg = '#b16286', bold = true },
    LualineModeReplace = { fg = '#282828', bg = '#cc241d', bold = true },
    LualineModeCommand = { fg = '#282828', bg = '#d65d0e', bold = true },

    -- Git highlighting
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.blue },
    GitSignsDelete = { fg = c.red },
  }

  -- Apply all highlight groups
  for group, styles in pairs(groups) do
    vim.api.nvim_set_hl(0, group, styles)
  end

  -- Return the palette for other modules to use
  return palette
end

local function configure_colors()
  -- Apply our custom theme
  my_custom_theme.setup()
end

local function configure_copilot()
  if not pcall(require, 'copilot') then
    print('copilot is not installed.')
    return
  end
  if not pcall(require, 'copilot_cmp') then
    print('copilot_cmp is not installed.')
    return
  end
  if not pcall(require, 'CopilotChat') then
    print('CopilotChat is not installed')
    return
  end

  if os.getenv('NVIM_ENABLE_COPILOT') ~= 'true' then
    return
  end

  -- You will need to call `:Copilot auth` to authenticate the device for
  -- the first time.

  -- Settings are defined at https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
  ---@diagnostic disable-next-line: undefined-field
  require('copilot').setup({
    panel = {
      enabled = false,
      auto_refresh = true,
    },
    suggestion = {
      enabled = false,
    },
    filetypes = {
      -- filetypes here can be boolean values or functions that return a boolean value.
      -- See https://github.com/zbirenbaum/copilot.lua#filetypes
      yaml = function()
        return os.getenv('NVIM_ENABLE_COPILOT') == 'true'
      end,
      markdown = function()
        -- TODO we might also allow turning it on and off for the current buffer.
        return os.getenv('NVIM_ENABLE_COPILOT_MARKDOWN') == 'true'
      end,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ['.'] = false,
      [''] = false,
      ['*'] = function()
        local buffer_number = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_var(buffer_number, COPILOT_ENABLED_VAR_NAME, true)

        return true
      end,
    },
    copilot_node_command = 'node', -- Node.js version must be > 18.x
    server_opts_overrides = {},
  })

  require('copilot_cmp').setup({})

  -- See https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file#default-configuration for the
  -- default configuration.
  require('CopilotChat').setup({
    debug = true,
    allow_insecure = false,

    model = get_copilot_ai_model(),
    context = 'buffers',

    window = {
      layout = 'float',
      relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
      border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
      width = 0.8, -- fractional width of parent
      height = 0.6, -- fractional height of parent
      title = 'Copilot Chat', -- title of chat window
      zindex = 1, -- determines if window is on top or below other floating windows
    },

    mappings = {
      close = {
        normal = '<C-c>',
      },
      reset = {
        normal = '<Del>',
      },
      complete = {
        insert = '<Tab>',
      },
      submit_prompt = {
        insert = '<CR>',
        normal = '<CR>',
      },
      accept_diff = {
        normal = 'a',
      },
      show_diff = {
        normal = 'gd',
      },
      show_info = {
        normal = 'gp',
      },
      show_context = {
        normal = 'gs',
      },
    },
  })
end

local function configure_git_blame()
  if not pcall(require, 'gitblame') then
    print('gitblame is not installed.')
    return
  end

  -- TODO add the git blame status to the status line
  -- https://github.com/f-person/git-blame.nvim#statusline-integration

  -- Add mappings for :GitBlameOpenFileURL and :GitBlameOpenCommitURL
  vim.cmd([[
    let g:gitblame_message_template = '  <author> • <date> • <summary>'
    let g:gitblame_date_format = '%Y-%m-%d (%r)'
  ]])
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

  vim.o.background = 'dark'

  if os.getenv('NVIM_ANSI_COLORS') == 'true' then
    vim.o.termguicolors = false
  else
    vim.o.termguicolors = true
  end

  -- This will render the trailing spaces and the tabs in a visible way.
  vim.o.listchars = 'tab:>-,trail:·'
  vim.o.list = true

  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true

  -- Not sure why but foldlevelstart is a global option, and the
  -- option folding options are at the window level...
  vim.o.foldlevelstart = 999
  -- Do not fold any of the block dy default.
  vim.o.foldlevel = 99

  -- TODO configure vim.o.wildignore ??

  if executable_is_available('rg') then
    vim.go.grepprg = "rg --vimgrep --hidden --glob '!.git/'"
    vim.go.grepformat = '%f:%l:%c:%m'
  else
    -- the grep related configuration is inspired by
    -- https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
    vim.go.grepprg = 'grep --binary-files=without-match --exclude-dir=target/ --exclude-dir=.git/ -rni'
  end
end

local function configure_nvim()
  vim.api.nvim_command('syntax on')

  -- Enable filetype detection
  vim.cmd([[
    filetype plugin on
    filetype plugin indent on
  ]])

  -- Calling packloadall is not necessary, because it will be called after
  -- running the init.lua anyway. Leaving here in case we want to load the plugins
  -- earlier in the future.
  -- vim.api.nvim_command('packloadall')
  --

  if os.getenv('NVIM_EMBEDDED') == 'true' then
    prepare_embedded_buffer()
  else
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function()
        vim.schedule(set_filetype_options)
      end,
    })
  end

  vim.cmd([[
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost [^l]* cwindow
        autocmd QuickFixCmdPost l* lwindow
    augroup END
  ]])

  -- Used to close all the buffers except the current buffer.
  vim.cmd([[
    command! BufOnly silent! execute "%bd|e#|bd#"
  ]])
end

local function configure_fzf()
  if not pcall(require, 'fzf-lua') then
    print('fzf-lua is not installed.')
    return
  end

  vim.keymap.set('n', '<c-P>', '<cmd>FzfLua files<CR>', { silent = true })
  vim.keymap.set('n', '<c-I>', '<cmd>FzfLua live_grep<CR>', { silent = true })

  -- See all the options here https://github.com/ibhagwan/fzf-lua#default-options
  require('fzf-lua').setup({
    winopts = {
      height = 0.85,
      width = 0.80,
      row = 0.35,
      col = 0.50,
    },
    previewers = {
      cat = {
        cmd = 'cat',
        args = '--number',
      },
    },
    files = {
      rg_opts = "--color=never --files --hidden --follow -g '!.git'",
    },
    grep = {
      rg_opts = "--hidden -g '!.git' --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
    },
  })
end

local function configure()
  if os.getenv('NVIM_EMBEDDED') == 'true' then
    prepare_embedded_buffer()
  end
  if os.getenv('NVIM_DISABLE_CONFIG') == 'true' then
    print('Config is disabled.')
    return
  end
  configure_nvim()
  configure_global_options()
  configure_key_bindings()
  configure_auto_format()
  configure_auto_completion()
  configure_commenting()
  configure_git_blame()
  configure_fzf()
  configure_lsp()
  configure_lastplace()
  configure_status_bar()
  configure_copilot()
  configure_colors()

  -- FIXME this is a workaround for the bug described in issue #30985 of the GitHub neovim repo.
  for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
      if err ~= nil and err.code == -32802 then
        return
      end
      return default_diagnostic_handler(err, result, context, config)
    end
  end
end

configure()
