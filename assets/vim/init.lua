local function configure()
  vim.wo.number = true
  vim.wo.relativenumber = true

  local colorscheme = "gruvbox"
  pcall(vim.cmd, "colorscheme " .. colorscheme)
end

return {
    configure = configure
}
