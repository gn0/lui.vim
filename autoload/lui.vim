" Location: autoload/lui.vim
" Author: Gábor Nyéki
" License: CC0

if exists("g:autoloaded_lui") || &cp
    finish
endif
let g:autoloaded_lui = v:true

" TODO If the scratch buffer is closed, call `jobstop()` via autocmd or
" something similar.
let s:placeholder = "[Running lui...]"
let s:last_cmd = #{ job_id: v:null, scratch_win: v:null }

function! s:is_placeholder(buf_id)
    let l:buffer = getbufline(a:buf_id, 1, "$")

    return len(l:buffer) == 1 && l:buffer[0] == s:placeholder
endfunction

function! lui#handle_output(channel_id, data, name)
    let l:current_win = win_getid()
    let l:scratch_win = s:last_cmd["scratch_win"]

    if l:scratch_win == v:null
        " User may have closed the scratch window manually, or with
        " `lui#stop`.
        "
        return
    endif

    let l:scratch_buf = winbufnr(l:scratch_win)

    if l:scratch_buf > 0
        if s:is_placeholder(l:scratch_buf)
            call setbufline(l:scratch_buf, 1, a:data)
        else
            call appendbufline(l:scratch_buf, "$", a:data)
        endif
    endif
endfunction

function! lui#run(bang, args, range, start, end)
    let l:job_opts = #{
                \   on_stdout: function("lui#handle_output"),
                \   on_stderr: function("lui#handle_output"),
                \   stdout_buffered: v:true
                \ }

    if a:range == 0
        let l:job_opts["stdin"] = "null"
        let command = "lui --no-stream " . a:args
    else
        let joined_lines = join(getline(a:start, a:end), "\n")
        let escaped = shellescape(
            \   substitute(joined_lines, "\\", "\\\\\\", "g")
            \ )
        let cleaned_lines = substitute(escaped, "'\\\\''", "\\\\'", "g")
        let command =
            \ "lui --no-stream " . a:args . " <<< $" . cleaned_lines
    endif

    let job_id = jobstart(command, l:job_opts)

    if job_id <= 0
        if job_id == 0
            call error("jobstart: invalid arguments")
        else
            echoerr "Is lui installed and located in $PATH?"
            call error("jobstart: lui is not executable")
        endif
    else
        if a:bang == "!" && s:last_cmd["scratch_win"] != v:null
            call win_execute(s:last_cmd["scratch_win"], "close!")
        endif

        let l:current_win = win_getid()

        let l:rows = winheight(0)
        let l:cols = winwidth(0)
        let l:ratio = 1.0 * l:cols / l:rows
        if l:ratio < 80.0 / 25.0
            new
        else
            vnew
        endif

        let w:scratch = 1
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
        setlocal nonumber norelativenumber ft=markdown

        call setline(1, s:placeholder)

        let s:last_cmd = #{ job_id: job_id, scratch_win: win_getid() }

        call win_gotoid(l:current_win)
    endif
endfunction

function! lui#stop()
    let l:job_id = s:last_cmd["job_id"]
    let l:scratch_win = s:last_cmd["scratch_win"]
    let l:scratch_buf = winbufnr(l:scratch_win)

    if l:job_id == v:null || jobstop(l:job_id) == 0
        echomsg "Lui is not running."
    elseif l:scratch_win != v:null
        if s:is_placeholder(l:scratch_buf)
            call win_execute(l:scratch_win, "close!")

            let s:last_cmd = #{ job_id: v:null, scratch_win: v:null }
        else
            call appendbufline(l:scratch_buf, "$", "[Stopped lui.]")
        endif
    endif
endfunction
