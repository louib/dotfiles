local function escape_termcode(raw_termcode)
    -- Adjust boolean arguments as needed
    return vim.api.nvim_replace_termcodes(raw_termcode, true, true, true)
end

local function configure()
  vim.api.nvim_command('syntax on')

  -- wo = window options
  -- bo = buffer options
  -- o = global options

  vim.o.encoding = 'utf8'

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

  local colorscheme = "gruvbox"
  pcall(vim.cmd, "colorscheme " .. colorscheme)
end

return {
    configure = configure
}
