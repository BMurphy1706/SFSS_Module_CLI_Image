-- Config is trying to be minimal as possible

-- Packages
vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/gbprod/nord.nvim',
    'https://github.com/daltonmenezes/aura-theme.git',
    'https://github.com/ericdwhite/overtones.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/mason-org/mason.nvim',
})

-- Extension needed for loading aura theme properly
vim.opt.rtp:append(
  vim.fn.stdpath("data") .. "/site/pack/core/opt/aura-theme/packages/neovim"
)

-- options
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'

vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true

vim.o.undofile = true
vim.o.inccommand = 'split'

vim.o.signcolumn = 'yes'
vim.o.updatetime = 250

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "open parent directory" })

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Color Setup
-- vim.cmd.colorscheme("aura-dark")
vim.cmd.colorscheme("overtones")

-- Transparency Setup - Uses terminal bg
vim.cmd [[ highlight Normal guibg=NONE ctermbg=NONE ]]

-- Telescope Setup
local builtin = require('telescope.builtin') 
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- LSP
--
require("mason").setup()

vim.lsp.enable({
    "gopls", 
    "pyright", 
    "zls", 
    "clangd",
    "lua-language-server",
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      vim.keymap.set('i', '<C-Space>', function()
        vim.lsp.completion.get()
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format()
  end,
})

vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
    },
})

-- Oil Setup
require("oil").setup({
    columns = {
        "icon",
        "permissions",
        "size",
        "ctime",
    }})
