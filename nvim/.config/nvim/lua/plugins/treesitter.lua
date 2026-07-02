return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "javascript",
      "typescript",
      "tsx",
      "lua",
      "go",
    },
    auto_install = true,
  },
}
