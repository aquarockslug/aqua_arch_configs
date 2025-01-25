-- minimal config for javascript
local vim = vim -- avoid undefined warnings
vim.g.mapleader = ","
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cmdheight = 0
vim.opt.autochdir = true
vim.opt.scrolloff = 1000
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.diagnostic.config({ signs = false })
vim.flag = "󰈿" -- TODO color flag

local setup_autocmds = function()
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function()
			require("mini.trailspace").trim()
			vim.notify(vim.flag .. ' wrote ' .. vim.fn.expand('%:p'), vim.log.levels.INFO)
		end
	})
	vim.api.nvim_create_autocmd("InsertEnter", {
		callback = function() Snacks.toggle.option("cursorline"):set(true) end
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function() Snacks.toggle.option("cursorline"):set(false) end
	})
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function() vim.highlight.on_yank { higroup = "DiffAdd", timeout = 250 } end })
end
local setup_keymap = function()
	local snacks = Snacks
	for cmd, func in pairs({
		a = vim.lsp.buf.hover,                           -- read documentation under cursor
		b = function() snacks.gitbrowse() end,
		c = function() require("mini.extra").pickers.hipatterns() end, -- view highlighted comments
		d = function() require("mini.extra").pickers.diagnostic() end,
		e = function() MiniFiles.open() end,
		r = function() require('grug-far').open() end, -- search and replace
		w = function() snacks.terminal() end,
	}) do vim.keymap.set("n", "<leader>" .. cmd, func) end
	vim.keymap.set("n", "<leader>/", vim.cmd.noh) -- clear highlighting

	for cmd, func in pairs({
		[1] = function() snacks.lazygit() end,
		[2] = function()
			vim.notify(vim.flag .. ' formatting...', vim.log.levels.INFO)
			vim.lsp.buf.format()
			vim.cmd.write()
		end,
		[3] = function() snacks.terminal.open('sh -c $(gum choose nap cht ddgr oil docs)') end,
		-- [4] next flag bookmark
	}) do
		vim.keymap.set("i", "<F" .. cmd .. ">", func)
		vim.keymap.set("n", "<F" .. cmd .. ">", func)
	end

	-- insert line above or below without going into insert mode
	vim.keymap.set('n', 'gO', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
	vim.keymap.set('n', 'go', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")

	vim.keymap.set("n", "U", "<c-r>")
	snacks.toggle.option("spell"):map("<leader>ts")
	snacks.toggle.diagnostics():map("<leader>td")
end
local setup_highlighters = function()
	vim.api.nvim_set_hl(0, 'MiniHipatternsWarn', { bg = "#FF5555", fg = "#FFFFFF" })
	vim.api.nvim_set_hl(0, 'MiniHipatternsHack', { bg = "#FFB86C" })
	vim.api.nvim_set_hl(0, 'MiniHipatternsTodo', { bg = "#8BE9FD" })
	-- vim.api.nvim_set_hl(0, 'MiniPickBorder', { fg = vim.dracula_green, bg = vim.dracula_bg })
	-- vim.api.nvim_set_hl(0, 'MiniPickPrompt', { fg = vim.dracula_orange, bg = vim.dracula_bg })
	-- vim.api.nvim_set_hl(0, 'MiniFilesBorder', { fg = vim.dracula_green, bg = vim.dracula_bg })
	-- vim.api.nvim_set_hl(0, 'MiniStatuslineModeOther', { fg = vim.dracula_orange })
	-- for _, group in ipairs({
	-- 	'MiniStatuslineModeNormal', 'MiniStatuslineModeInsert', 'MiniStatuslineDevinfo', 'MiniStatuslineFileinfo',
	-- 	'MiniStatuslineFilename', 'MiniJump', 'MiniJump2dSpot', 'MiniStarterHeader', 'MiniStarterFooter',
	-- 	'MiniStarterQuery', 'GrugFarInputLabel', 'GrugFarHelpHeader', 'MiniNotifierBorderInfo', 'MiniNotifierTitleInfo'
	-- }) do vim.api.nvim_set_hl(0, group, { fg = vim.dracula_orange }) end
	-- vim.api.nvim_set_hl(0, 'ColorColumn', { bg = vim.dracula_green }) TODO fix color col color
end

-- MINI
local path_package = vim.fn.stdpath('data') .. '/site_light/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
	vim.notify('Installing mini.nvim', vim.log.levels.INFO)
	vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path })
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.notify('Installed mini.nvim', vim.log.levels.INFO)
end
require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
for _, plug in ipairs({
	"basics", "comment", "diff", "jump", "jump2d", "ai", "pairs", "surround", "trailspace", "files", "pick",
}) do later(function() require('mini.' .. plug).setup() end) end

-- SNACKS
now(function()
	add({ source = 'folke/snacks.nvim' });
	require('snacks').setup({
		bigfile = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		rename = { enabled = true },
	})
	require('snacks').indent.enable()
end)

-- BLINK
now(function()
	add({
		source = 'Saghen/blink.cmp',
		depends = { 'neovim/nvim-lspconfig', 'rafamadriz/friendly-snippets' },
	})
	require("blink.cmp").setup { keymap = { preset = 'super-tab' } }
	require("lspconfig")["biome"].setup {}
	require("lspconfig")["lua_ls"].setup {}
end)

-- OTHER
now(function()
	require('mini.hipatterns').setup({
		highlighters = {
			warn = { pattern = '%f[%w]()WARN()%f[%W]', group = 'MiniHipatternsWarn' },
			hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
			todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
		}
	})
end)
now(function()
	add({ source = 'sphamba/smear-cursor.nvim' }); require('smear_cursor').setup()
	add({ source = '2giosangmitom/nightfall.nvim' }); require("nightfall").setup({})
	vim.cmd.colorscheme('deepernight') -- 'nightfall', 'maron'
end)
now(function()
	add({ source = 'MeanderingProgrammer/render-markdown.nvim' });
	require('render-markdown').setup({});
	require('render-markdown').enable()
end)
later(function() -- search and replace
	add({ source = 'MagicDuck/grug-far.nvim' }); require('grug-far').setup {}

	add({ source = 'tzachar/highlight-undo.nvim' })
	require('highlight-undo').setup()

	add({ source = 'andrewferrier/debugprint.nvim' }) -- generates print statements for variables
	require('debugprint').setup({ keymaps = { normal = { variable_below = "gp", delete_debug_prints = "gP" } } })
end)
later(function()
	add({ source = 'chentoast/marks.nvim' }); require('marks').setup { -- builtin_marks = { "<", ">", "^", "." },
		mappings = {                                        -- up/down navigates marks, left right navigates flag bookmark
			next_bookmark0 = '<F4>',
			set_bookmark0 = ',f',
			delete_bookmark0 = ',F'
		},
		bookmark_0 = {
			sign = vim.flag,
			virt_text = vim.flag,
		},
	}
end)
later(function()
	add({
		source = 'nvim-treesitter/nvim-treesitter',
		checkout = 'master',
		monitor = 'main',
		hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
	})
	require('nvim-treesitter.configs').setup({ highlight = { enable = true } })
end)
later(function()
	add({ source = 'swaits/zellij-nav.nvim' })
	require('zellij-nav').setup()
	vim.keymap.set("n", "<up>", function() vim.cmd("ZellijNavigateUp") end)
	vim.keymap.set("n", "<down>", function() vim.cmd("ZellijNavigateDown") end)
	vim.keymap.set("n", "<left>", function() vim.cmd("ZellijNavigateLeft") end)
	vim.keymap.set("n", "<right>", function() vim.cmd("ZellijNavigateRight") end)
end)
local is_wsl = function() -- check if nvim is currently running on windows subsystem linux
	local version_file = io.open("/proc/version", "rb")
	if version_file ~= nil and string.find(version_file:read("*a"), "microsoft") then
		version_file:close()
		return true
	end
	return false
end
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
if is_wsl() then                  -- https://github.com/memoryInject/wsl-clipboard
	vim.g.clipboard = {
		name = "wsl-clipboard",
		copy = { ["+"] = "wcopy", ["*"] = "wcopy" },
		paste = { ["+"] = "wpaste", ["*"] = "wpaste" },
		cache_enabled = true,
	}
end
setup_autocmds(); setup_highlighters(); setup_keymap()
