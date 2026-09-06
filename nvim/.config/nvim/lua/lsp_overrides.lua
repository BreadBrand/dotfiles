-- Explicit vim.lsp.config() calls always take precedence over lsp/*.lua
-- files found on the runtimepath, regardless of load order. This matters
-- because vim.pack.add() appends plugins to 'runtimepath' after this
-- config dir, so nvim-lspconfig's own lsp/sqls.lua (root_markers =
-- {'config.yml'}) was clobbering our lsp/sqls.lua override entirely.
local data_source = os.getenv("SQLS_DATA_SOURCE")
local root_markers = { '.sqls.yml', '.git' }

-- sqls has no built-in support for auto-loading a project-local .sqls.yml:
-- it only reads config via -config, a global ~/.config/sqls/config.yml, or
-- connections pushed by the client through workspace/didChangeConfiguration
-- (see sqls internal/handler/handler.go). root_markers only gets sqls's
-- root_dir pointed at the right directory; it doesn't make sqls read the
-- file there. So when there's no SQLS_DATA_SOURCE override, parse the
-- project's .sqls.yml ourselves and push it the same way.
local function read_sqls_connections(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()

  local connections = {}
  local current
  for line in content:gmatch("[^\r\n]+") do
    if line:match("^%s*%- ") then
      current = {}
      table.insert(connections, current)
      line = line:gsub("^%s*%- ", "")
    end
    local key, value = line:match("^%s*(%a+):%s*(.-)%s*$")
    if key and current then
      current[key] = value:gsub('^"(.*)"$', '%1')
    end
  end

  return #connections > 0 and connections or nil
end

vim.lsp.config('sqls', {
  root_markers = root_markers,
  settings = data_source and {
    sqls = {
      connections = {
        { driver = "postgresql", dataSourceName = data_source },
      },
    },
  } or nil,
  on_init = function(client)
    if data_source or not client.root_dir then return end
    local connections = read_sqls_connections(client.root_dir .. "/.sqls.yml")
    if not connections then return end
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
      sqls = { connections = connections },
    })
    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
  end,
})
