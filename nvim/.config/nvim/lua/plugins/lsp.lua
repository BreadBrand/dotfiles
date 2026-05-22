return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {},
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<return>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ['<C-x>'] = cmp.mapping.close(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
        }),
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        -- add border to completion menu
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    init = function()
      vim.opt.signcolumn = 'yes'
    end,
    config = function()
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or 'rounded'
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      local default_capabilities = vim.lsp.protocol.make_client_capabilities()
      local capabilities = vim.tbl_deep_extend(
        'force',
        default_capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc, noremap = true, silent = true })
          end
          map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Show hover docs')
          map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', 'Go to definition')
          map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', 'Go to declaration')
          map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', 'Go to implementation')
          map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', 'Go to type definition')
          map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', 'List references')
          map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Show signature help')
          map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
          map({ 'n', 'x' }, '<leader>vf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', 'Format buffer')
          map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code action')
        end,
      })

      local function find_root(patterns)
        return function(fname)
          local filepath
          if type(fname) == "string" then
            filepath = fname
          elseif type(fname) == "number" then
            filepath = vim.api.nvim_buf_get_name(fname)
          else
            filepath = vim.api.nvim_buf_get_name(0)
          end

          if filepath == "" or filepath == nil then
            filepath = vim.fn.getcwd()
          end

          local found = vim.fs.find(patterns, { path = filepath, upward = true })
          return found[1] and vim.fs.dirname(found[1]) or vim.fn.getcwd()
        end
      end

      vim.lsp.config.dartls = {
        cmd = { 'dart', 'language-server', '--protocol=lsp' },
        filetypes = { 'dart' },
        root_dir = find_root({ "pubspec.yaml", "analysis_options.yaml" }),
        init_options = {
          closingLabels = true,
          flutterOutline = true,
          onlyAnalyzeProjectsWithOpenFiles = true,
          outline = true,
          suggestFromUnimportedLibraries = true,
        },
        settings = {
          dart = {
            completeFunctionCalls = true,
            showTodos = true,
          },
        },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          print('Dart language server started')
        end,
      }

      vim.lsp.config.eslint = {
        root_dir = find_root({ 'eslint.config.mjs', 'package.json' }),
        settings = {
          eslint = {
            workingDirectories = { mode = 'auto' }
          }
        },
        capabilities = capabilities,
      }

      vim.lsp.config.ts_ls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        capabilities = capabilities,
      }

      vim.lsp.config.cssls = {
        filetypes = { "css", "scss", "less" },
        capabilities = capabilities,
      }

      vim.lsp.config.gopls = {
        filetypes = { "go", "gomod", "gowork" },
        capabilities = capabilities,
      }

      require('mason-lspconfig').setup({
        ensure_installed = {},
        handlers = {
          function(server_name)
            -- Skip servers manually configured above
            if server_name == 'dartls' or server_name == 'eslint' then
              return
            end
            -- For other servers, use the new API with default config
            if not vim.lsp.config[server_name] then
              vim.lsp.config[server_name] = {}
            end
            -- Merge with capabilities
            vim.lsp.config[server_name] = vim.tbl_deep_extend('force', vim.lsp.config[server_name] or {}, {
              capabilities = capabilities,
            })
            vim.lsp.enable(server_name)
          end,
        }
      })
    end
  }
}
