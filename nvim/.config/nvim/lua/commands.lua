vim.api.nvim_create_user_command("PackAdd", function(opts)
  vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "add plugins (:PackAdd user/repo/1 user/repo/2)" })

vim.api.nvim_create_user_command("PackDel", function(opts)
  vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "delete plugins (:PackDel plugin1 plugin2)" })


vim.api.nvim_create_user_command("PackUp", function(opts)
  if opts.args:match("%S") then
    local plugins = vim.split(opts.args, "%s+", { trimempty = true })
    vim.pack.update(plugins)
  else
    vim.pack.update()
  end
end, { nargs = "+", desc = "update all plugins or specified ones" })
