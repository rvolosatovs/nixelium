let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1

" Deoplete
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['var', 'func', 'type', 'package', 'const']

nmap <M-r> <Plug>(go-run)
nmap <M-t> <Plug>(go-test)
nmap <M-c> <Plug>(go-coverage)
