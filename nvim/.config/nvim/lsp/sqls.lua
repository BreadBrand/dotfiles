local data_source = os.getenv("SQLS_DATA_SOURCE")

if not data_source then
  -- No override: let sqls pick up a project-local .sqls.yml instead.
  return {}
end

return {
  settings = {
    sqls = {
      connections = {
        { driver = "postgresql", dataSourceName = data_source },
      },
    },
  },
}
