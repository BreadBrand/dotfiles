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
end, { nargs = "*", desc = "update all plugins or specified ones" })

--- auto-check for plugin updates, throttled to once per day ---
local function pack_autoupdate()
  local stamp_path = vim.fn.stdpath("state") .. "/pack_update_stamp"
  local one_day = 24 * 60 * 60
  local stat = vim.uv.fs_stat(stamp_path)

  if stat and (os.time() - stat.mtime.sec) < one_day then
    return
  end

  local fd = io.open(stamp_path, "w")
  if fd then
    fd:write(tostring(os.time()))
    fd:close()
  end

  vim.cmd("PackUp")
end

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "check for plugin updates once per day",
  callback = function()
    vim.schedule(pack_autoupdate)
  end,
})
