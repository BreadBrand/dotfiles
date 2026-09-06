local function on_jump(diagnostic, bufnr)
  if not diagnostic then return end

  vim.diagnostic.open_float()
end

vim.diagnostic.config({
  virtual_text = true,
  jump = { on_jump = on_jump },
})
