--------------------------------------------------------
-- 🚀 Configuration complète Neovim (Windows + Git Bash)
-- Version : "VSCode++ amélioré"
--------------------------------------------------------

-- ==========  Vérifie et charge lazy.nvim ==========
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

-- ==========  Plugins ==========
require("lazy").setup({
  -- 🧠 Base
  { "nvim-lua/plenary.nvim" },

  -- 🌈 Thèmes multiples
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "EdenEast/nightfox.nvim" },

  -- 📁 Explorateur de fichiers
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- 📜 Barre de statut
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- 🎨 Arbre syntaxique moderne
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- 🔍 Recherche rapide
  { "nvim-telescope/telescope.nvim" },

  -- ⚙️ LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- 💬 Autocomplétion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- ✨ Plus d’UI et couleurs
  { "norcalli/nvim-colorizer.lua" }, -- color picker
  { "lukas-reineke/indent-blankline.nvim" }, -- indentation guides
    ---------------------------------------------------
  -- 🔥 JS/TS Specific Plugins
  ---------------------------------------------------
  -- Treesitter JS/TS enhancements
  { "JoosepAlviste/nvim-ts-context-commentstring" }, -- context aware comments

  -- ESLint / Prettier integration
  { "jose-elias-alvarez/null-ls.nvim" }, -- pour linting et format
  { "MunifTanjim/prettier.nvim" },      -- prettier integration

  -- JS/TS Autocomplete snippets
  { "rafamadriz/friendly-snippets" },

  -- Refactoring / Navigation JS/TS
  { "ThePrimeagen/refactoring.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Debugging
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" },
  { "theHamsta/nvim-dap-virtual-text" },

  -- Git
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim" },

  -- Telescope extensions
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
})

--------------------------------------------------------
-- 🌙 Apparence et thème
--------------------------------------------------------
-- Choix de thème rapide
vim.g.mapleader = " "
local themes = { "tokyonight", "catppuccin", "nightfox" }
local current_theme = 1
vim.cmd("colorscheme " .. themes[current_theme])

-- Raccourci pour changer de thème
vim.keymap.set("n", "<leader>tt", function()
  current_theme = current_theme % #themes + 1
  vim.cmd("colorscheme " .. themes[current_theme])
end, { noremap = true, silent = true })

-- Barre et explorateur
require("lualine").setup({ options = { theme = "auto" } })
require("nvim-tree").setup({ view = { width = 40 }, update_focused_file = { enable = true } })

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "cpp", "rust", "c_sharp", "javascript", "lua", "json", "bash", "python" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- Colorizer pour voir les couleurs CSS/hex
require("colorizer").setup()

-- Indentation guides
require("indent_blankline").setup({ show_current_context = true })

--------------------------------------------------------
-- 🧠 LSP + Autocomplétion
--------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",         -- C++
    "rust_analyzer",  -- Rust
    "ts_ls",          -- JS / TS
    "lua_ls",         -- Lua
    "omnisharp",      -- C#
  },
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local servers = { "clangd", "rust_analyzer", "ts_ls", "lua_ls", "omnisharp" }

for _, server in ipairs(servers) do
  lspconfig[server].setup({ capabilities = capabilities })
end

--------------------------------------------------------
-- ⚡ Autocomplétion nvim-cmp
--------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

--------------------------------------------------------
-- ⚙️ Raccourcis utiles
--------------------------------------------------------
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-f>", ":Telescope live_grep<CR>", { noremap = true, silent = true })

--------------------------------------------------------
-- 🪄 Réglages de base
--------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
