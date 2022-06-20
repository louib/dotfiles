local function configure()
  -- wo = window options
  -- bo = buffer options
  -- o = global options

  vim.o.encoding = 'utf8'

  -- Make searching case insensitive
  vim.o.ignorecase = true
  -- ... unless the query has capital letters.
  vim.o.smartcase = true

  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true

  local colorscheme = "gruvbox"
  pcall(vim.cmd, "colorscheme " .. colorscheme)
end

return {
    configure = configure
}
