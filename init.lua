local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "EdenEast/nightfox.nvim" },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-telescope/telescope.nvim" },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "norcalli/nvim-colorizer.lua" },
  { "lukas-reineke/indent-blankline.nvim" },
  { "JoosepAlviste/nvim-ts-context-commentstring" },
  { "jose-elias-alvarez/null-ls.nvim" },
  { "MunifTanjim/prettier.nvim" },
  { "ThePrimeagen/refactoring.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- JS / TS
  { "pmizio/typescript-tools.nvim" },
  { "dmmulroy/tsc.nvim" },
  { "windwp/nvim-ts-autotag" },

  -- C#
  { "Hoffs/omnisharp-extended-lsp.nvim" },
  { "j-hui/fidget.nvim", tag = "legacy" },

  -- C++
  { "p00f/clangd_extensions.nvim" },
  { "Civitasv/cmake-tools.nvim" },

  -- Rust
  { "simrat39/rust-tools.nvim" },
  { "saecki/crates.nvim", version = "v0.3.0" },

  -- UI & outils LSP
  { "nvimdev/lspsaga.nvim", config = true },
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "ray-x/lsp_signature.nvim" },
  { "akinsho/toggleterm.nvim", version = "*" },
})

vim.g.mapleader = " "
local themes = { "tokyonight", "catppuccin", "nightfox" }
local current_theme = 1
vim.cmd("colorscheme " .. themes[current_theme])
vim.keymap.set("n", "<leader>tt", function()
  current_theme = current_theme % #themes + 1
  vim.cmd("colorscheme " .. themes[current_theme])
end, { noremap = true, silent = true })

require("lualine").setup({ options = { theme = "auto" } })
require("nvim-tree").setup({ view = { width = 40 }, update_focused_file = { enable = true } })

require("nvim-treesitter.configs").setup({
  ensure_installed = { "cpp", "rust", "c_sharp", "javascript", "lua", "json", "bash", "python" },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true },
})

require("colorizer").setup()
require("indent_blankline").setup({ show_current_context = true })
require("toggleterm").setup()

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",
    "rust_analyzer",
    "ts_ls",
    "lua_ls",
    "omnisharp",
  },
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local servers = { "clangd", "rust_analyzer", "ts_ls", "lua_ls", "omnisharp" }

for _, server in ipairs(servers) do
  lspconfig[server].setup({ capabilities = capabilities })
end

require("clangd_extensions").setup()
require("rust-tools").setup()
require("crates").setup()
require("lspsaga").setup({})
require("fidget").setup({})
require("lsp_signature").setup({ hint_enable = false })

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-f>", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", ":TroubleToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true })

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
