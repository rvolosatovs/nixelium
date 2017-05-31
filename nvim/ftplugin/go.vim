let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_autosave = 1
"let g:go_auto_type_info = 1
let g:go_fmt_command = "goimports"

call deoplete#custom#set('go', 'rank', 9999)

let g:deoplete#sources#go#sort_class = ['package', 'var', 'func', 'const', 'type']
let g:deoplete#sources#go#gocode_binary = $GOBIN.'/gocode'
let g:deoplete#sources#go#use_cache = 1
let g:deoplete#sources#go#json_directory = '$XDG_CACHE_HOME/deoplete/go/linux_amd64'
let g:deoplete#sources#go#cgo = 0
let g:deoplete#sources#go#pointer = 1
let g:deoplete#sources#go#package_dot = 0
let g:deoplete#sources#go#auto_goos = 1

nmap <M-r> <Plug>(go-run)
nmap <M-t> <Plug>(go-test)
nmap <M-c> <Plug>(go-coverage)
