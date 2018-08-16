let g:hindent_on_save = 1
let g:stylishask_on_save = 1

" Disable haskell-vim omnifunc
let g:haskellmode_completion_ghc = 0

" neco-ghc
setlocal omnifunc=necoghc#omnifunc 
let g:necoghc_enable_detailed_browse = 1

let g:haskell_classic_highlighting = 1
let g:haskell_indent_if = 3
let g:haskell_indent_case = 2
let g:haskell_indent_let = 4
let g:haskell_indent_where = 6
let g:haskell_indent_before_where = 2
let g:haskell_indent_after_bare_where = 2
let g:haskell_indent_do = 3
let g:haskell_indent_in = 1
let g:haskell_indent_guard = 2
let g:haskell_indent_case_alternative = 1
let g:cabal_indent_section = 2

" Insert type declaration
nnoremap <silent> <leader>ht :InteroTypeInsert<CR>
" Show info about expression or type under the cursor
nnoremap <silent> <leader>hi :InteroInfo<CR>

" Open/Close the Intero terminal window
nnoremap <silent> <leader>hn :InteroOpen<CR>
nnoremap <silent> <leader>hh :InteroHide<CR>

" Reload the current file into REPL
nnoremap <silent> <leader>hf :InteroLoadCurrentFile<CR>
" Jump to the definition of an identifier
nnoremap <silent> <leader>hg :InteroGoToDef<CR>
" Evaluate an expression in REPL
nnoremap <silent> <leader>he :InteroEval<CR>

" Start/Stop Intero
nnoremap <silent> <leader>hs :InteroStart<CR>
nnoremap <silent> <leader>hk :InteroKill<CR>

au BufWritePost *.hs InteroReload
