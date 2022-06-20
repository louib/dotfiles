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

  local colorscheme = "sonokai"
  -- local colorscheme = "gruvbox"
  pcall(vim.cmd, "colorscheme " .. colorscheme)
end

return {
    configure = configure
}
