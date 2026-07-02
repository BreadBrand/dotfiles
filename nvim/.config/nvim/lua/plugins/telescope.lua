return {
  'nvim-telescope/telescope.nvim',
  event = 'VeryLazy',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  config = function()
    require('telescope').setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules/.*",
          "%.env",
          "yarn.lock",
          "package-lock.json",
          "lazy-lock.json",
          "init.sql",
          "target/.*",
          ".git/.*",
        },
        mappings = {
          i = {
            ["<CR>"] = function(prompt_bufnr)
              local action_state = require("telescope.actions.state")
              vim.g.last_telescope_search = action_state.get_current_line()
              require("telescope.actions").select_default(prompt_bufnr)
            end,
          },
        },
      },
    })

    vim.api.nvim_create_user_command("TelescopeLastSearch", function()
      local search_term = vim.g.last_telescope_search or ""
      require("telescope.builtin").find_files({
        default_text = search_term,
      })
    end, {})

    vim.api.nvim_create_user_command("TelescopeLastGrep", function()
      local search_term = vim.g.last_telescope_search or ""
      require("telescope.builtin").live_grep({
        default_text = search_term
      })
    end, {})

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Search buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Search help tags' })
    vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Resume telescope search' })
    vim.keymap.set('n', '<leader>gr', builtin.lsp_references, { desc = 'Open LSP References' })
    vim.keymap.set('n', '<leader>fWs', function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end, { desc = 'Grep string under cursor' })
    vim.keymap.set('n', '<leader>fls', function()
      vim.cmd("TelescopeLastSearch")
    end, { desc = 'Open Telescope with the last file search conducted' })
    vim.keymap.set('n', '<leader>gls', function()
      vim.cmd("TelescopeLastGrep")
    end, { desc = 'Open Telescope with the last grep search conducted' })
  end
}
