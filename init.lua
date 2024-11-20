-- soft blink yanked region 
vim.api.nvim_create_autocmd('textyankpost', {
  callback=function()
    vim.highlight.on_yank({ timeout=200 })
  end,
})

vim.opt.visualbell = true
vim.opt.errorbells = false

vim.opt.hlsearch=false
-- vim.opt.ignorecase=true
vim.opt.smartcase=true
vim.g.mapleader=','
vim.opt.clipboard="unnamedplus" -- Sync with system clipboard
vim.api.nvim_set_keymap('n', '<Leader>oo', 'O<esc>j<esc>o<esc>k', { noremap = true, silent = true })


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
{ "catppuccin/nvim", name = "catppuccin", priority = 1000, cond = (function() return not vim.g.vscode end) },
{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}, cond = (function() return not vim.g.vscode end) },
{ "Mofiqul/vscode.nvim", cond = (function() return not vim.g.vscode end) },
{
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function() require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
    })
    end
},
{
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}
  end,
},
{
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
},
{
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
},
{
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "html", "cssls","lua_ls", "ts_ls" },
      })
    end,
},
{
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
      },
    },
}
})

if vim.g.neovide then
  vim.o.guifont="JetBrainsMono Nerd Font:h11" -- text below applies for VimScript
  vim.opt.relativenumber=true
  vim.opt.number=true
  vim.opt.autoindent=true
  vim.opt.tabstop=4
  vim.opt.shiftwidth=4
  vim.opt.autoindent=true
  vim.opt.startofline=true
end

if vim.g.vscode then
  local vscode = require('vscode')

  -- Avoid cursor to unfold
  local function mapMove(key, direction)
    vim.keymap.set('n', key, function()
      local count = vim.v.count
      local v = 1
      local style = 'wrappedLine'
      if count > 0 then
        v = count
        style = 'line'
      end
      vscode.action('cursorMove', {
        args = {
          to = direction,
          by = style,
          value = v
        }
      })
    end, options)
  end

  -- Toggle Pin Tab
  vim.keymap.set('n', '<leader>p', function()
      vscode.eval_async([[
          if (vscode.window.tabGroups.activeTabGroup.activeTab.isPinned) {
            await vscode.commands.executeCommand('workbench.action.unpinEditor');
          } else {
              await vscode.commands.executeCommand('workbench.action.pinEditor');
          }
      ]])
  end)

  -- Code Run
  vim.api.nvim_set_keymap('n', '<Leader>r', "<Cmd>lua require('vscode').action('code-runner.run')<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<Leader>c', "<Cmd>lua require('vscode').action('workbench.output.action.clearOutput')<CR>", { noremap = true, silent = true })

  -- undo/redo via vscode
  if vim.g.vscode then
    vim.keymap.set("n","u","<Cmd>call VSCodeNotify('undo')<CR>")
    vim.keymap.set("n","<C-r>","<Cmd>call VSCodeNotify('redo')<CR>") 
  end

  -- Folding
  vim.keymap.set('n', 'za', ':call VSCodeNotify("editor.toggleFold")<cr>', { desc = 'toggle fold' })
  vim.keymap.set('n', 'zM', ':call VSCodeNotify("editor.foldAll")<cr>', { desc = 'fold all' })
  vim.keymap.set('n', 'zR', ':call VSCodeNotify("editor.unfoldAll")<cr>', { desc = 'unfold all' })

  -- Navigation
  vim.keymap.set('n', '<Tab>', function()
    require('vscode-neovim').action('togglePeekWidgetFocus') 
  end)
  -- vim.keymap.set('n', '<S-Tab>', function()
  --   require('vscode-neovim').action('workbench.action.previousEditor') 
  -- end)

  -- Marks
  vim.keymap.set('n', ']d', ':call VSCodeNotify("editor.action.marker.next")<cr>')
  vim.keymap.set('n', '[d', ':call VSCodeNotify("editor.action.marker.prev")<cr>')

  -- Togle/Focus sidebar options
  vim.keymap.set('n', '<Leader>t', function()
    require('vscode-neovim').action('workbench.action.toggleSidebarVisibility') 
  end)
  vim.keymap.set('n', '<Leader>b', function()
    require('vscode-neovim').action('workbench.action.toggleActivityBarVisibility') 
  end)
  -- Go to next/previous symbol highlighted
  vim.keymap.set('n', '*', function()
    require('vscode-neovim').action('editor.action.wordHighlight.next') 
  end)
  vim.keymap.set('n', '#', function()
    require('vscode-neovim').action('editor.action.wordHighlight.prev') 
  end)
  -- Get word under cursor into fin in all files seach input 
  vim.api.nvim_set_keymap('n', '?', [[<Cmd>lua require('vscode').action('workbench.action.findInFiles', { args = { query = vim.fn.expand('<cword>') } })<CR>]], { noremap = true, silent = true })
  -- Close Others
  vim.keymap.set('n', '<Leader>o', function()
    require('vscode-neovim').action('workbench.action.closeOtherEditors') 
  end)
  -- Search and Replace
  vim.api.nvim_set_keymap(
    "n",
    "<Leader>f",
    [[<Cmd>call VSCodeNotify('editor.actions.findWithArgs', { 'searchString': expand('<cword>'), 'replaceString': '' })<CR>]],
    { noremap = true, silent = true }
  )

  vim.api.nvim_set_keymap(
    "n",
    "/",
    [[<Cmd>call VSCodeNotify('editor.actions.findWithArgs', { 'searchString': expand('<cword>'), 'replaceString': '' })<CR>]],
    { noremap = true, silent = true }
  )

  -- Add Selection to Next Match
  vim.keymap.set({ "n", "x", "i" }, "<C-d>", function()
   vscode.with_insert(function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
   end)
  end)

  -- Go to Implementation, Declaration, Symbol
  vim.keymap.set('n', 'gi', function()
    require('vscode-neovim').action('editor.action.goToImplementation') 
  end)
  vim.keymap.set('n', 'gf', function()
    require('vscode-neovim').action('editor.action.goToDeclaration') 
  end)
  vim.keymap.set('n', 'gO', function()
    require('vscode-neovim').action('workbench.action.gotoSymbol') 
  end)

  -- Split Window
  vim.keymap.set('n', '<Leader>sl', function()
    require('vscode-neovim').action('workbench.action.splitEditorToRightGroup') 
  end)
  vim.keymap.set('n', '<Leader>sh', function()
    require('vscode-neovim').action('workbench.action.splitEditorToLeftGroup') 
  end)
  vim.keymap.set('n', '<Leader>sj', function()
    require('vscode-neovim').action('workbench.action.splitEditorToBelowGroup') 
  end)
  vim.keymap.set('n', '<Leader>sk', function()
    require('vscode-neovim').action('workbench.action.splitEditorToAboveGroup') 
  end)
else
  vim.opt.cursorline=true 
  vim.opt.termguicolors=true -- True color support
  vim.opt.sessionoptions={ "buffers", "curdir", "tabpages", "winsize" }
  vim.opt.number=true
  vim.opt.tabstop=4
  vim.opt.shiftwidth=4
  vim.opt.shiftround=true -- Round indent
  vim.opt.relativenumber=true
  vim.opt.breakindent=true
  vim.opt.autoindent=true
  vim.opt.autoindent=true
  vim.opt.startofline=true
  vim.opt.list=true
  vim.opt.expandtab=true
  vim.opt.undofile=true
  vim.opt.undofile = true
  vim.opt.inccommand="nosplit"
  vim.opt.incsearch=true
  vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
  vim.opt.mouse="a"


  -- disable netrw at the very start of your init.lua
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  -- empty setup using defaults
  require("nvim-tree").setup()

  require('lspconfig').html.setup {}
  require('lspconfig').cssls.setup {}
  require('lspconfig').lua_ls.setup {
    settings = {
        Lua = {
        diagnostics = {
            globals = {'vim'},
        },
        },
    },
  }
  require('lspconfig').ts_ls.setup {}

  vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

  -- vim.cmd.colorscheme "catppuccin" -- colorscheme catppuccin " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
  vim.cmd.colorscheme "vscode" -- colorscheme catppuccin " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
end
