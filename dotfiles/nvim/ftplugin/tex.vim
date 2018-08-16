let g:Tex_ViewRule_pdf = 'zathura'
let g:Tex_ViewRule_dvi = 'zathura'
let g:Tex_ViewRule_ps = 'zathura'
let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'
let g:Tex_DefaultTargetFormat = 'pdf'

if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif
let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete
