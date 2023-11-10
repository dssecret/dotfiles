vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('n', '<Space>', '<Nop>', {silent=true, remap=false})

-- Install lazy package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

-- Setup packages via lazy
require('lazy').setup({
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'neovim/nvim-lspconfig',
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function ()
			local config = require('nvim-treesitter.configs')

			config.setup({
				ensure_installed = {
					'lua',
					'vim',
					'javascript',
					'html',
					'python'
				},
				sync_install = false,
				highlight = {
					enable = true
				},
				indent = {
					enable = true
				}
			})
		end
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrshth/nvim-cmp'
		}
	},
	{
		-- Snippet engine for nvim/cmp
		'L3MON4D3/LuaSnip',
		version = 'v2.*',
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.4',
		dependencies = {'nvim-lua/plenary.nvim'}
	},
	{
		'nvim-telescope/telescope-file-browser.nvim',
		dependencies = {'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim'}
	},
	{
		'nvim-telescope/telescope-live-grep-args.nvim',
		dependencies = {'nvim-telescope/telescope.nvim'}
	},
	{
		'folke/tokyonight.nvim',
		lazy = false,
		config = function()
			vim.cmd('colorscheme tokyonight-night')
		end
	},
	'andweeb/presence.nvim',
})

-- auto-completion config
local cmp = require('cmp')

cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered()
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),  -- overlaps with tmux
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({select = true})
	}),
	sources = cmp.config.sources({
		{name = 'nvim_lsp'},
		{name = 'luasnip'}
	}, {
		{name = 'buffer'},
	})
})
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{name = 'git'},
	}, {
		{name = 'buffer'}
	})
})
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = {'pylsp', 'quick_lint_js', 'lua_ls'},
	automatic_installation = true
})
require('lspconfig').pylsp.setup({
	capabilities = capabilities,
	pylsp = {
		configurationSources = {'flake8', 'black'},
		plugins = {
			autopep8 = {enabled = false},
			black = {enabled = true, line_length=120},
			flake8 = {enabled = true, indentSize=4, maxLineLength=120},
			pycodestyle = {enabled = false},
			pydocstyle = {enabled = false},
			pylint = {enabled = false},
			rope_autoimport = {enabled = false},
			rope_completion = {enabled = false}
		}
	}
})
require('lspconfig').clangd.setup{}
require('lspconfig').lua_ls.setup({
	capabilities = capabilities
})

local builtin = require('telescope.builtin')

require('telescope').setup({
	extensions = {
		file_browser = {
			theme = 'ivy',
			hijack_netrw = true
		},
		live_grep_args = {
			auto_quoting = true
		}
	}
})

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', ':lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>', {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>r', ':Telescope resume<CR>', {})
vim.keymap.set('n', '<leader>R', ':Telescope pickers<CR>', {})

vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope file_browser<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', {noremap = true})
require('telescope').load_extension('file_browser')
