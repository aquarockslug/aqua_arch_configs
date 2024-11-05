-- Aqua's nvim

-- vim settings
local vim = vim               -- avoid undefined warnings
vim.g.mapleader = ","
vim.opt.mousescroll = "ver:1" -- fixes scrolling with mini.animate
vim.opt.autochdir = true
vim.opt.scrolloff = 1000
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3         -- set the styling of the file list to be a tree
vim.loader.enable()
vim.keymap.set("n", "U", "<C-r>") -- undo

local setup_autocmds = function()
	vim.api.nvim_create_autocmd("BufWritePost", { callback = require("mini.trailspace").trim })
	vim.api.nvim_create_autocmd('TextYankPost', {
		callback = function() vim.highlight.on_yank { higroup = 'DiffAdd', timeout = 250 } end,
	})
end

-- % leader shortcuts %
local setup_keymap = function()
	for cmd, func in pairs({
		d = require("divider").toggle_outline, -- navigate dividers
		g = require("mini.pick").builtin.grep_live, -- find words
		f = function() require("mini.extra").pickers.lsp({ scope = "document_symbol" }) end,
		h = vim.cmd.noh, -- clear highlighting
		j = ":move+<CR>==", -- shift line up
		k = ":move-2<CR>==", -- shift line down
		o = require("mini.extra").pickers.oldfiles,
		r = function() require("mini.extra").pickers.lsp({ scope = "references" }) end,
		s = require("mini.extra").pickers.spellsuggest,
		v = vim.cmd.Vexplore, -- open netrw in vertical pane
		V = vim.cmd.Hexplore, -- open netrw in horizontal pane
		y = require("mini.extra").pickers.registers,
	}) do
		vim.keymap.set("n", "<leader>" .. cmd, func)
	end
end

local setup_highlighters = function()
	vim.api.nvim_set_hl(0, 'MiniHipatternsFixme', { bg = "#FF5555", fg = "#FFFFFF" })
	vim.api.nvim_set_hl(0, 'MiniHipatternsHack', { bg = "#FFB86C", fg = "#000000" })
	vim.api.nvim_set_hl(0, 'MiniHipatternsTodo', { bg = "#8BE9FD", fg = "#000000" })
end

-- % WSL %
local is_wsl = function() -- check if nvim is currently running on windows subsystem linux
	local version_file = io.open("/proc/version", "rb")
	if version_file ~= nil and string.find(version_file:read("*a"), "microsoft") then
		version_file:close()
		return true
	end
	return false
end

if is_wsl() then -- https://github.com/memoryInject/wsl-clipboard
	vim.g.clipboard = {
		name = "wsl-clipboard",
		copy = { ["+"] = "wcopy", ["*"] = "wcopy" },
		paste = { ["+"] = "wpaste", ["*"] = "wpaste" },
		cache_enabled = true,
	}
end

-- PLUGINS
-- % setup mini.deps %
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local function build_blink(params)
	vim.notify('Building blink.cmp', vim.log.levels.INFO)
	local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
	if obj.code == 0 then
		vim.notify('Building blink.cmp done', vim.log.levels.INFO)
	else
		vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
	end
end

-- % NOW %
now(function() require('mini.icons').setup() end)
now(function()
	add({ source = 'prichrd/netrw.nvim' }); require("netrw").setup({});
end)
now(function() require('mini.statusline').setup() end)
now(function() require('mini.starter').setup() end)
now(function()
	require('mini.notify').setup()
	vim.notify = require('mini.notify').make_notify()
end)
now(function() -- theme
	add({ source = 'Mofiqul/dracula.nvim', as = 'dracula' })
	require("dracula").setup({ italic_comment = true, transparent_bg = true })
	vim.cmd([[colorscheme dracula]])
end)
now(function()
	add({ source = 'niuiic/divider.nvim' }); require("divider").setup({})
end)
now(function() -- terminal
	add({ source = 'akinsho/toggleterm.nvim' })
	local Terminal = require("toggleterm.terminal").Terminal
	vim.floater = function(cmd)
		return Terminal:new({ cmd = cmd, direction = "float" })
	end
	vim.markdown = function()
		return Terminal:new({
			cmd = "glow --pager " .. vim.fn.expand("%:p"),
			direction = "vertical"
		}):toggle()
	end

	vim.keymap.set('n', '<leader>t', function() vim.floater("zsh"):toggle() end)

	for cmd, func in pairs({
		[1] = function() -- git
			vim.floater("lazygit"):toggle()
		end,
		[2] = function() -- format and save
			vim.lsp.buf.format(); vim.cmd.write()
		end,
		[3] = function() -- menu: web search, web bookmarks, browse notes
			vim.floater('$(gum choose "ddgr" "oil" "tldr")'):toggle()
		end,
		[4] = function() -- snippet browser
			vim.floater("nap"):toggle()
		end,
	}) do
		vim.keymap.set("n", "<F" .. cmd .. ">", func)
	end
end)
later(function() -- lsp and completion
	add({
		source = 'Saghen/blink.cmp',
		depends = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim',
			'neovim/nvim-lspconfig', 'rafamadriz/friendly-snippets' },
		hooks = { --  blink.cmp doesnt use the stable version of rust
			post_install = build_blink, post_checkout = build_blink,
		},
	})
	require("mason").setup()
	require("mason-lspconfig").setup {}
	require("blink.cmp").setup {}
	for _, lang_server in ipairs({
		"lua_ls", "basedpyright", "bashls", "biome", "csharp_ls"
	}) do require("lspconfig")[lang_server].setup {} end
end)
now(function() -- highlight patterns
	local hipatterns = require('mini.hipatterns')
	hipatterns.setup({
		highlighters = {
			fixme = { pattern = '%f[%w]()WARN()%f[%W]', group = 'MiniHipatternsFixme' },
			hack  = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
			todo  = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
		}
	})
end)
-- % LATER %
for _, plug in ipairs({
	"ai", "animate", "bracketed", "comment", "diff", "doc", "extra", "fuzzy", "jump",
	"misc", "operators", "pairs", "pick", "splitjoin", "surround", "trailspace",
}) do later(function() require('mini.' .. plug).setup() end) end
later(function() require("mini.indentscope").setup({ symbol = "󰈿" }) end)
later(function() add({ source = 'simeji/winresizer' }) end)         -- <C-e> to resize, then 'e' to move
later(function() add({ source = 'kwkarlwang/bufresize.nvim' }) end) -- automatically update buffer size
later(function()                                                    -- movement
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

setup_autocmds()
setup_keymap()
setup_highlighters()
