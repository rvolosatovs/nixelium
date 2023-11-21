--- Imports

require('lsp_extensions')

telescope = require('telescope.builtin')

local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')
local illuminate = require('illuminate')
local indent_blankline = require('ibl')
local luasnip = require('luasnip')
local treesitter = require('nvim-treesitter.configs')

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

function noremap_lua_buf(bufnr, bind, command)
    vim.api.nvim_buf_set_keymap(bufnr, "", bind, '<cmd>lua ' .. command .. '<cr>', { noremap = true })
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
vim.opt.viewoptions = 'cursor,slash,unix'
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

--- Completion

local cmp_map_pre = function(f)
    cmp.mapping(function(fallback)
        f()
        fallback()
    end, { 'i', 's' })
end
local cmp_confirm_insert = cmp_map_pre(function()
    cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
    })
end)

cmp.setup {
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = {
        ['<C-d>']   = cmp.mapping.scroll_docs(4),
        ['<C-e>']   = cmp.mapping.close(),
        ['<C-n>']   = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                cmp.complete()
            end
        end, { 'i', 's' }),
        ['<C-p>']   = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.mapping.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-u>']   = cmp.mapping.scroll_docs(-4),
        ['<down>']  = cmp.mapping.select_next_item(),
        ['<esc>']   = cmp_map_pre(cmp.mapping.close),
        ['<up>']    = cmp.mapping.select_prev_item(),

        ['(']       = cmp_confirm_insert,
        [')']       = cmp_confirm_insert,
        ['-']       = cmp_confirm_insert,
        ['<']       = cmp_confirm_insert,
        ['<cr>']    = cmp_confirm_insert,
        ['<space>'] = cmp_confirm_insert,
        ['>']       = cmp_confirm_insert,
        ['[']       = cmp_confirm_insert,
        ['\\']      = cmp_confirm_insert,
        [']']       = cmp_confirm_insert,
        ['{']       = cmp_confirm_insert,
        ['|']       = cmp_confirm_insert,
        ['}']       = cmp_confirm_insert,
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    sources = {
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'treesitter' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'calc' },
        { name = 'spell' },
        { name = 'emoji' },
    },
    view = {
        entries = "native",
    },
}

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

local capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_attach = function(client, bufnr)
    print('LSP loaded.')

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    illuminate.on_attach(client)

    for k, fn in pairs({
        ['<C-]>']      = 'telescope.lsp_definitions()',
        ['<C-k>']      = 'vim.lsp.buf.signature_help()',
        ['<leader>a']  = 'vim.lsp.buf.code_action()',
        ['<leader>A']  = 'vim.lsp.buf.range_code_action()',
        ['<leader>dd'] = 'telescope.diagnostics()',
        ['<leader>dl'] = 'vim.lsp.diagnostic.set_loclist()',
        ['<leader>f']  = 'vim.lsp.buf.format{ async = true }',
        ['<leader>r']  = 'vim.lsp.buf.rename()',
        ['<leader>sa'] = 'vim.lsp.buf.add_workspace_folder()',
        ['<leader>sl'] = 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
        ['<leader>sr'] = 'vim.lsp.buf.remove_workspace_folder()',
        ['[d']         = 'vim.lsp.diagnostic.goto_prev()',
        [']d']         = 'vim.lsp.diagnostic.goto_next()',
        ['gc']         = 'vim.lsp.buf.incoming_calls()',
        ['gC']         = 'vim.lsp.buf.outgoing_calls()',
        ['gd']         = 'telescope.lsp_implementations()',
        ['gD']         = 'vim.lsp.buf.declaration()',
        ['gr']         = 'telescope.lsp_references()',
        ['gs']         = 'telescope.lsp_document_symbols()',
        ['gS']         = 'telescope.lsp_dynamic_workspace_symbols()',
        ['gT']         = 'vim.lsp.buf.type_definition()',
        ['K']          = 'vim.lsp.buf.hover()',
    }) do
        noremap_lua_buf(bufnr, k, fn)
    end

    vim.api.nvim_command [[ hi def link LspReferenceText CursorLine ]]
end

local lspconfig = require('lspconfig')
lspconfig.bashls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['bash-language-server'], 'start' },
}
lspconfig.clangd.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['clangd'], '--background-index' },
}
lspconfig.dockerls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['docker-langserver'], '--stdio' },
}
lspconfig.elmls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['elm-language-server'] },
    settings = {
        elmLS = {
            elmFormatPath = paths.bin['elm-format'],
        },
        elmPath = paths.bin['elm'],
        elmTestPath = paths.bin['elm-test'],
    },
}
lspconfig.gdscript.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
lspconfig.gopls.setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        noremap_lua_buf(bufnr, '<leader>i', 'goimports(bufnr, 10000)')
    end,
    cmd = { paths.bin['gopls'], 'serve' },
    settings = {
        gopls = {
            analyses = {
                fieldalignment = true,
                unusedparams = true,
            },
            gofumpt = true,
            staticcheck = true,
        },
    },
}
lspconfig.hls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['haskell-language-server'], '--lsp' },
}
lspconfig.julials.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        julia = {
            executablePath = paths.bin['julia'],
        },
    },
}
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    cmd = { paths.bin['lua-language-server'] },
    on_attach = on_attach,
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                Lua = {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME
                        }
                    }
                }
            })

            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
    end
}
lspconfig.nil_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['nil'] },
    settings = {
        ['nil'] = {
            formatting = { command = { paths.bin['alejandra'] } }
        }
    }
}
lspconfig.omnisharp.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['omnisharp'], '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
}
lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { paths.bin['rust-analyzer'] },
    settings = {
        ['rust-analyzer'] = {
            imports = { preferNoStd = true }
        }
    }
}

--- Diagnostics

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
    }
)
