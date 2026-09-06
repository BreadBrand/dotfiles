local function on_jump(diagnostic, bufnr)
  if not diagnostic then return end

  vim.diagnostic.open_float()
end

vim.diagnostic.config({
  virtual_text = true,
  jump = { on_jump = on_jump },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})
