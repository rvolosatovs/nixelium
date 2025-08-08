--- Imports

telescope = require('telescope.builtin')

local blink = require('blink.cmp')
local indent_blankline = require('ibl')
local mini_base16 = require('mini.base16')
local mini_bracketed = require('mini.bracketed')
local mini_pairs = require('mini.pairs')
local mini_surround = require('mini.surround')
local treesitter = require('nvim-treesitter.configs')

--- Colorscheme
mini_base16.setup {
    palette = {
        -- TODO: Unify with Nix config
        base00 = '#1d1f21',
        base01 = '#282a2e',
        base02 = '#373b41',
        base03 = '#969896',
        base04 = '#b4b7b4',
        base05 = '#c5c8c6',
        base06 = '#e0e0e0',
        base07 = '#ffffff',
        base08 = '#cc6666',
        base09 = '#de935f',
        base0A = '#f0c674',
        base0B = '#b5bd68',
        base0C = '#8abeb7',
        base0D = '#81a2be',
        base0E = '#b294bb',
        base0F = '#a3685a',
    },
}

--- Functions

function goimports(bufnr, timeoutms)
    local context = { source = { organizeImports = true } }
    vim.validate { context = { context, 't', true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    local method = 'textDocument/codeAction'
    local resp = vim.lsp.buf_request_sync(bufnr, method, params, timeoutms)
    if resp and resp[1] then
        local result = resp[1].result
        if result and result[1] then
            local edit = result[1].edit
            vim.lsp.util.apply_workspace_edit(edit)
        end
    end
    vim.lsp.buf.format { async = true }
end

function map_lua_buf(bufnr, bind, command)
    vim.keymap.set('n', bind, '<cmd>lua ' .. command .. '<cr>', { buffer = bufnr })
end

--- Options

vim.opt.autoindent = true
vim.opt.autowriteall = true
vim.opt.backup = true
vim.opt.cmdheight = 2
vim.opt.concealcursor = 'nc'
vim.opt.conceallevel = 0
vim.opt.confirm = true
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.encoding = 'utf-8'
vim.opt.expandtab = true
vim.opt.fileencoding = 'utf-8'
vim.opt.fileformat = 'unix'
vim.opt.foldcolumn = 'auto:3'
vim.opt.foldlevel = 16
vim.opt.gdefault = true
vim.opt.grepprg = paths.bin.ripgrep .. ' --vimgrep'
vim.opt.guicursor = ""
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = 'nosplit'
vim.opt.incsearch = true
vim.opt.mouse = 'a'
vim.opt.nrformats = 'alpha,octal,hex,bin'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.signcolumn = 'yes'
vim.opt.smartcase = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.visualbell = true
vim.opt.wrapscan = true

-- use space as the leader key
vim.g.mapleader = ' '

--- Autocommands

vim.api.nvim_command [[ autocmd TextYankPost * silent! lua require('highlight').on_yank('IncSearch', 500, vim.v.event) ]]

--- Keybindings

local cmd = function(v) return '<cmd>' .. v .. '<cr>' end
local lua = function(v) return cmd('lua ' .. v) end
local plg = function(v) return '<plug>' .. v end

for _, v in ipairs({
    -- general
    { '<A-h>',             '<C-\\><C-N><C-w>h',                { "i", "t" }, { noremap = true } },
    { '<A-h>',             '<C-w>h',                           { "" },       { noremap = true } },
    { '<A-j>',             '<C-\\><C-N><C-w>j',                { "i", "t" }, { noremap = true } },
    { '<A-j>',             '<C-w>j',                           { "" },       { noremap = true } },
    { '<A-k>',             '<C-\\><C-N><C-w>k',                { "i", "t" }, { noremap = true } },
    { '<A-k>',             '<C-w>k',                           { "" },       { noremap = true } },
    { '<A-l>',             '<C-\\><C-N><C-w>l',                { "i", "t" }, { noremap = true } },
    { '<A-l>',             '<C-w>l',                           { "" },       { noremap = true } },
    { '<leader>"',         lua('telescope.registers()'),       { "" },       { noremap = true } },
    { '<leader>*',         lua('telescope.grep_string()'),     { "" },       { noremap = true } },
    { '<leader>-',         lua('telescope.file_browser()'),    { "" },       { noremap = true } },
    { '<leader>/',         lua('telescope.search_history()'),  { "" },       { noremap = true } },
    { '<leader>:',         lua('telescope.command_history()'), { "" },       { noremap = true } },
    { '<leader>;',         lua('telescope.commands()'),        { "" },       { noremap = true } },
    { '<leader>?',         lua('telescope.live_grep()'),       { "" },       { noremap = true } },
    { '<leader>cd',        cmd('cd %:p:h<cr>:pwd'),            { "" },       { noremap = true } },
    { '<leader>e',         lua('telescope.find_files()'),      { "" },       { noremap = true } },
    { '<leader>H',         lua('telescope.help_tags()'),       { "" },       { noremap = true } },
    { '<leader>h',         lua('telescope.oldfiles()'),        { "" },       { noremap = true } },
    { '<leader>j',         lua('telescope.jumplist()'),        { "" },       { noremap = true } },
    { '<leader>M',         lua('telescope.man_pages()'),       { "" },       { noremap = true } },
    { '<leader>m',         lua('telescope.marks()'),           { "" },       { noremap = true } },
    { '<leader>o',         lua('telescope.vim_options()'),     { "" },       { noremap = true } },
    { '<leader>p',         lua('telescope.builtin()'),         { "" },       { noremap = true } },
    { '<leader>Q',         cmd('q'),                           { "" },       { noremap = true } },
    { '<leader>S',         lua('telescope.spell_suggest()'),   { "" },       { noremap = true } },
    { '<leader>T',         lua('telescope.filetypes()'),       { "" },       { noremap = true } },
    { '<leader>w',         cmd('w'),                           { "" },       { noremap = true } },
    { '<leader>W',         cmd('wa'),                          { "" },       { noremap = true } },
    { '<space>',           '<nop>',                            { "" },       { noremap = true } },
    { 'Y',                 'y$',                               { "" },       { noremap = true } },

    -- quickfix
    { '<leader>q',         lua('telescope.quickfix()'),        { "" },       { noremap = true } },

    -- loclist
    { '<leader>l',         lua('telescope.loclist()'),         { "" },       { noremap = true } },

    -- buffers
    { '<leader>b',         lua('telescope.buffers()'),         { "" },       { noremap = true } },

    -- treesitter
    { '<leader>t',         lua('telescope.treesitter()'),      { "" },       { noremap = true } },

    -- git
    { '<leader>ge',        lua('telescope.git_files()'),       { "" },       { noremap = true } },
    { '<leader>gs',        lua('telescope.git_status()'),      { "" },       { noremap = true } },
    { '<leader>gt',        lua('telescope.git_bcommits()'),    { "" },       { noremap = true } },
    { '<leader>gT',        lua('telescope.git_commits()'),     { "" },       { noremap = true } },
    { '<leader>gy',        lua('telescope.git_stash()'),       { "" },       { noremap = true } },

    -- NERD Commenter
    { '<leader>c$',        plg('NERDCommenterToEOL'),          { "" },       {} },
    { '<leader>c<leader>', plg('NERDCommenterToggle'),         { "" },       {} },
    { '<leader>cA',        plg('NERDCommenterAppend'),         { "" },       {} },
    { '<leader>cy',        plg('NERDCommenterYank'),           { "" },       {} },

}) do
    for _, mode in ipairs(v[3]) do
        vim.api.nvim_set_keymap(mode, v[1], v[2], v[4])
    end
end

--- Blankline

indent_blankline.setup {
    indent = { char = { '|', '¦', '┆', '┊' } },
}

--- Treesitter

treesitter.setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    indent = {
        enable = true,
    },
}

--- LSP

---@module 'blink.cmp'
---@type blink.cmp.Config
blink.setup {
    completion = { documentation = { auto_show = true } },
}
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        print('LSP loaded.')

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true)
        else
            print("no inlay hints available")
        end
        vim.g.diagnostics_visible = true

        for k, fn in pairs({
            ['<C-]>']      = 'vim.lsp.buf.definition()',
            ['<C-k>']      = 'vim.lsp.buf.signature_help()',
            ['<leader>dd'] = 'telescope.diagnostics()',
            ['<leader>dl'] = 'vim.lsp.diagnostic.set_loclist()',
            ['<leader>f']  = 'vim.lsp.buf.format{ async = true }',
            ['<leader>r']  = 'vim.lsp.buf.rename()',
            ['<leader>sa'] = 'vim.lsp.buf.add_workspace_folder()',
            ['<leader>sl'] = 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
            ['<leader>sr'] = 'vim.lsp.buf.remove_workspace_folder()',
            ['[d']         = 'vim.lsp.diagnostic.goto_prev()',
            [']d']         = 'vim.lsp.diagnostic.goto_next()',
            ['gD']         = 'vim.lsp.buf.declaration()',
            ['gT']         = 'vim.lsp.buf.type_definition()',
        }) do
            map_lua_buf(ev.buf, k, fn)
        end

        vim.api.nvim_command [[ hi def link LspReferenceText CursorLine ]]
    end,
})

vim.lsp.config.bashls = {
    cmd = { paths.bin['bash-language-server'], 'start' },
}
vim.lsp.config.clangd = {
    cmd = { paths.bin['clangd'], '--background-index' },
}
vim.lsp.config.cssls = {
    cmd = { paths.bin['vscode-css-language-server'], '--stdio' },
}
vim.lsp.config.dockerls = {
    cmd = { paths.bin['docker-langserver'], '--stdio' },
}
vim.lsp.config.eslint = {
    cmd = { paths.bin['vscode-eslint-language-server'], '--stdio' },
}
vim.lsp.config.gopls = {
    on_attach = function(_, bufnr)
        map_lua_buf(bufnr, '<leader>i', 'goimports(bufnr, 10000)')
    end,
    cmd = { paths.bin['gopls'], 'serve' },
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            gofumpt = true,
            staticcheck = true,
        },
    },
}
vim.lsp.config.hls = {
    cmd = { paths.bin['haskell-language-server'], '--lsp' },
}
vim.lsp.config.html = {
    cmd = { paths.bin['vscode-html-language-server'], '--stdio' },
}
vim.lsp.config.julials = {
    settings = {
        julia = {
            executablePath = paths.bin['julia'],
        },
    },
}
vim.lsp.config.lua_ls = {
    cmd = { paths.bin['lua-language-server'] },
    settings = {
        Lua = {}
    },
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath('config')
                and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    'lua/?.lua',
                    'lua/?/init.lua',
                },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                }
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
            }
        })
    end
}
vim.lsp.config.nil_ls = {
    cmd = { paths.bin['nil'] },
    settings = {
        ['nil'] = {
            formatting = { command = { paths.bin['alejandra'] } }
        }
    }
}
vim.lsp.config.omnisharp = {
    cmd = { paths.bin['omnisharp'], '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
}
vim.lsp.config.rust_analyzer = {
    cmd = { paths.bin['rust-analyzer'] },
    settings = {
        ['rust-analyzer'] = {
            assist = {
                emitMustUse = true,
            },
            imports = {
                granularity = {
                    enforce = true,
                },
                preferNoStd = true,
            },
            inlayHints = {
                closureCaptureHints = {
                    enable = true,
                },
                closureReturnTypeHints = {
                    enable = true,
                },
                discriminantHints = {
                    enable = true,
                },
                rangeExclusiveHints = {
                    enable = true,
                },
            }
        }
    }
}
vim.lsp.config.taplo = {
    cmd = { paths.bin['taplo'], 'lsp', 'stdio' },
}
vim.lsp.config.ts_ls = {
    cmd = { paths.bin['typescript-language-server'], '--stdio' },
}
vim.lsp.enable({
    'bashls',
    'clangd',
    'cssls',
    'dockerls',
    'eslint',
    'gdscript',
    'hls',
    'html',
    'julials',
    'lua_ls',
    'nil_ls',
    'omnisharp',
    'rust_analyzer',
    'taplo',
    'ts_ls',
})

--- Diagnostics

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
    }
)

--- Pairs
mini_pairs.setup {}

--- Surround
mini_surround.setup {}

--- Bracketed
mini_bracketed.setup {}
