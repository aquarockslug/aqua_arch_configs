local vim = vim

-- setup mini.nvim
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

vim.o.termguicolors = true
vim.g.mapleader = ","
vim.opt.mousescroll = "ver:1" -- fixes scrolling with mini.animate
vim.opt.termguicolors = true
vim.opt.autochdir = true
vim.opt.scrolloff = 1000

vim.keymap.set("n", "U", "<C-r>") -- undo
for cmd, func in pairs({
	h = vim.cmd.noh,          -- clear highlighting
	j = ":move+<CR>==",       -- shift line up
	k = ":move-2<CR>==",      -- shift line down
	e = vim.cmd.Texplore,     -- open netrw in new tab
	v = vim.cmd.Vexplore,     -- open netrw in vertical pane
	V = vim.cmd.Hexplore,     -- open netrw in horizontal pane
}) do
	vim.keymap.set("n", "<leader>" .. cmd, func)
end

vim.api.nvim_create_autocmd("BufWritePost", { callback = require("mini.trailspace").trim })
vim.api.nvim_create_autocmd("TextYankPost", { callback = vim.highlight.on_yank })

-- PLUGINS
require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function() require('mini.icons').setup() end)
now(function() require('mini.tabline').setup() end)
now(function() require('mini.statusline').setup() end)
now(function() require('mini.starter').setup() end)
now(function()
	require('mini.notify').setup()
	vim.notify = require('mini.notify').make_notify()
end)

-- OPT PLUGINS ( non mini.nvim plugins )
now(function() -- theme
	add({ source = 'Mofiqul/dracula.nvim', as = 'dracula' })
	require("dracula").setup({ italic_comment = true, transparent_bg = true })
	vim.cmd([[colorscheme dracula]])
end)

now(function() -- terminal
	add({ source = 'akinsho/toggleterm.nvim' })

	local Terminal = require("toggleterm.terminal").Terminal
	vim.floater = function(cmd) return Terminal:new({ cmd = cmd, direction = "float" }) end
	vim.open_glow = function() return vim.floater("glow --pager " .. vim.fn.expand("%:p")):toggle() end

	vim.keymap.set('n', '<leader>t', function() vim.floater("zsh"):toggle() end)

	for cmd, func in pairs({
		[1] = function() -- git
			vim.floater("lazygit"):toggle()
		end,
		[2] = function() -- format and save
			vim.lsp.buf.format()
			vim.cmd.write()
		end,
		[3] = function() -- view current file with glow
			-- TODO: quick open note if not a markdown buffer
			vim.open_glow()
		end,
		[4] = function() -- menu: web search, web bookmarks, browse notes
			vim.floater('$(gum choose "ddgr" "oil" "tldr")'):toggle()
		end,
		[5] = function() -- file browser
			vim.floater("nap"):toggle()
		end,
	}) do
		vim.keymap.set("n", "<F" .. cmd .. ">", func)
	end
end)

now(function() -- lsp and completion
	add({
		source = 'Saghen/blink.cmp',
		depends = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim',
			'neovim/nvim-lspconfig', 'rafamadriz/friendly-snippets' },
	})
	require("mason").setup()
	require("mason-lspconfig").setup {}
	require('blink.cmp').setup {}
	require('lspconfig').lua_ls.setup {}
	require('lspconfig').ast_grep.setup {}
	require('lspconfig').basedpyright.setup {}
	require('lspconfig').omnisharp.setup {}
	require('lspconfig').bashls.setup {}
end)


later(function() require('mini.ai').setup() end)
later(function() require('mini.comment').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.doc').setup() end)
later(function() require('mini.fuzzy').setup() end)
later(function() require('mini.hipatterns').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('mini.pick').setup() end)
later(function() require('mini.surround').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.trailspace').setup() end)
later(function() require('mini.splitjoin').setup() end)
later(function() require('mini.animate').setup() end)
later(function() require("mini.indentscope").setup({ symbol = "󰈿" }) end)

-- file manager, use "o" and "v" to open the selected file in a new window
later(function() add({ source = 'prichrd/netrw.nvim' }) end)
-- manage buffers, <C-e> to resize, then 'e' agian to switch to move mode
later(function() add({ source = 'simeji/winresizer' }) end)
later(function() add({ source = 'kwkarlwang/bufresize.nvim' }) end)

later(function() -- movement
	add({ source = 'swaits/zellij-nav.nvim' })
	require('zellij-nav').setup()

	vim.keymap.set("n", "<up>", function() vim.cmd("ZellijNavigateUp") end)
	vim.keymap.set("n", "<down>", function() vim.cmd("ZellijNavigateDown") end)
	vim.keymap.set("n", "<left>", function() vim.cmd("ZellijNavigateLeft") end)
	vim.keymap.set("n", "<right>", function() vim.cmd("ZellijNavigateRight") end)

	vim.keymap.set("n", "<C-up>", vim.cmd.tabs)
	vim.keymap.set("n", "<C-down>", vim.cmd.quit)
	vim.keymap.set("n", "<C-left>", vim.cmd.tabprevious)
	vim.keymap.set("n", "<C-right>", vim.cmd.tabnext)
end)

later(function() -- treesitter
	add({
		source = 'nvim-treesitter/nvim-treesitter',
		checkout = 'master',
		monitor = 'main',
		hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
	})
	require('nvim-treesitter.configs').setup({ highlight = { enable = true } })
end)
