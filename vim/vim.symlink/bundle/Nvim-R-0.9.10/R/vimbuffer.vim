" This file contains code used only when R run in Neovim buffer

function ExeOnRTerm(cmd)
    let curwin = winnr()
    exe 'sb ' . g:rplugin_R_bufname
    exe a:cmd
    call cursor("$", 1)
    exe curwin . 'wincmd w'
endfunction

function SendCmdToR_Buffer(...)
    if IsJobRunning(g:rplugin_jobs["R"]) || 1
        if g:R_clear_line
            let cmd = "\001" . "\013" . a:1
        else
            let cmd = a:1
        endif

        "if !exists("g:R_hl_term")
        "    call SendToNvimcom("\x08" . $NVIMR_ID . 'paste(search(), collapse=" ")')
        "    let g:rplugin_lastev = ReadEvalReply()
        "    if !exists("g:R_hl_term")
        "        if g:rplugin_lastev =~ "colorout"
        "            let g:R_hl_term = 0
        "        else
        "            let g:R_hl_term = 1
        "        endif
        "    endif
        "endif

        "if !exists("s:hl_term")
        "    let s:hl_term = g:R_hl_term
        "    if s:hl_term
        "        call ExeOnRTerm('set filetype=rout')
        "    endif
        "endif

        " Update the width, if necessary
        if g:R_setwidth && len(filter(tabpagebuflist(), "v:val =~ bufnr(g:rplugin_R_bufname)")) >= 1
            call ExeOnRTerm("let s:rwnwdth = winwidth(0)")
            if s:rwnwdth != s:R_width && s:rwnwdth != -1 && s:rwnwdth > 10 && s:rwnwdth < 999
                let s:R_width = s:rwnwdth
                if has("win32")
                    let cmd = "options(width=" . s:R_width. "); ". cmd
                else
                    call SendToNvimcom("\x08" . $NVIMR_ID . "options(width=" . s:R_width. ")")
                    sleep 10m
                endif
            endif
        endif

        if a:0 == 2 && a:2 == 0
            call term_sendkeys(g:term_bufn, cmd)
        else
            call term_sendkeys(g:term_bufn, cmd . "\n")
        endif
        return 1
    else
        call RWarningMsg("Is R running?")
        return 0
    endif
endfunction

function StartR_InBuffer()
    if string(g:SendCmdToR) != "function('SendCmdToR_fake')"
        return
    endif
    let g:R_tmux_split = 0

    let g:SendCmdToR = function('SendCmdToR_NotYet')

    let edbuf = bufname("%")
    let objbrttl = b:objbrtitle
    let curbufnm = bufname("%")
    set switchbuf=useopen

    if g:R_rconsole_width > 0 && winwidth(0) > (g:R_rconsole_width + g:R_min_editor_width + 1 + (&number * &numberwidth))
        if g:R_rconsole_width > 16 && g:R_rconsole_width < (winwidth(0) - 17)
            silent exe "belowright " . g:R_rconsole_width . "vnew"
        else
            silent belowright vnew
        endif
    else
        if g:R_rconsole_height > 0 && g:R_rconsole_height < (winheight(0) - 1)
            silent exe "belowright " . g:R_rconsole_height . "new"
        else
            silent belowright new
        endif
    endif

    if has("win32")
        call SetRHome()
    endif

    if len(g:rplugin_r_args)
        let rcmd = g:rplugin_R . " " . join(g:rplugin_r_args)
    else
        let rcmd = g:rplugin_R
    endif
    if g:R_close_term
        let g:term_bufn = term_start(rcmd,
                    \ {'exit_cb': function('ROnJobExit'), "curwin": 1, "term_finish": "close"})
    else
        let g:term_bufn = term_start(rcmd,
                    \ {'exit_cb': function('ROnJobExit'), "curwin": 1})
    endif
    let g:rplugin_jobs["R"] = term_getjob(g:term_bufn)

    if has("win32")
        redraw
        call UnsetRHome()
    endif
    let g:rplugin_R_bufname = bufname("%")
    let s:R_width = 0
    let b:objbrtitle = objbrttl
    let b:rscript_buffer = curbufnm
    if exists("g:R_hl_term") && g:R_hl_term
        set filetype=rout
        let s:hl_term = g:R_hl_term
    endif
    "if g:R_esc_term
    "    tnoremap <buffer> <Esc> <C-\><C-n>
    "endif
    exe "sbuffer " . edbuf
    "stopinsert
    call WaitNvimcomStart()
endfunction

if has("win32")
    " The R package colorout only works on Unix systems
    let g:R_hl_term = get(g:, "R_hl_term", 1)
    " R may crash if R_setwidth = 1 on Windows
endif
let g:R_setwidth = get(g:, "R_setwidth", 1)
