" lui.vim - Pipe region or whole buffer to an LLM using lui
" Location: plugin/lui.vim
" Author: Gábor Nyéki
" Version: 1.0
" License: CC0

if exists("g:loaded_lui") || &cp
    finish
endif
let g:loaded_lui = v:true

command! -nargs=1 -complete=command -bang -range Lui call
            \ lui#run(<q-bang>, <q-args>, <range>, <line1>, <line2>)
command! -nargs=0 LuiStop call lui#stop()

" XXX
" nnoremap <Plug>Lui :call lui#run()<CR>
