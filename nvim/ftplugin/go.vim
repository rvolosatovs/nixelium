let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
" Have issues with guru
let g:go_auto_type_info = 0

nmap <M-r> <Plug>(go-run)
nmap <M-t> <Plug>(go-test)
nmap <M-c> <Plug>(go-coverage)
