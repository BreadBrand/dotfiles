local data_source = os.getenv("SQLS_DATA_SOURCE")

-- nvim-lspconfig's built-in root_markers = { 'config.yml' } doesn't match
-- sqls's actual default config filename, so root_dir never resolves and
-- sqls never finds a project's .sqls.yml. Override it here.
local root_markers = { '.sqls.yml', '.git' }

if not data_source then
  -- No override: let sqls pick up a project-local .sqls.yml instead.
  return { root_markers = root_markers }
end

return {
  root_markers = root_markers,
  settings = {
    sqls = {
      connections = {
        { driver = "postgresql", dataSourceName = data_source },
      },
    },
  },
}
