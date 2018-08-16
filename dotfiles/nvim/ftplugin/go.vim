let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_extra_types = 0
let g:go_highlight_fields = 0
let g:go_highlight_format_strings = 1
let g:go_highlight_function_arguments = 0
let g:go_highlight_function_calls = 1
let g:go_highlight_functions = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_interfaces = 0
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_types = 0
let g:go_highlight_variable_assignments = 0
let g:go_highlight_variable_declarations = 0
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 0
"let g:go_def_mode = "guru"

call deoplete#custom#source('go', 'rank', 9999)

let g:deoplete#sources#go#sort_class = ['package', 'var', 'func', 'const', 'type']
let g:deoplete#sources#go#gocode_binary = $GOBIN.'/gocode'
let g:deoplete#sources#go#cgo = 0
let g:deoplete#sources#go#pointer = 1
let g:deoplete#sources#go#package_dot = 0
let g:deoplete#sources#go#auto_goos = 1

nmap <Leader>R <Plug>(go-run)
nmap <Leader>T <Plug>(go-test)
nmap <Leader>C <Plug>(go-coverage)
