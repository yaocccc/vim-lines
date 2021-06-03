if exists('s:loaded') | finish | endif
let s:loaded = 1

let g:line_mode_map=get(g:, 'line_mode_map', { "n": "NORMAL", "v": "VISUAL", "V": "V-LINE", "\<c-v>": "V-CODE", "i": "INSERT", "R": "R", "r": "R", "Rv": "V-REPLACE", "c": "CMD-IN", "s": "SELECT", "S": "SELECT", "\<c-s>": "SELECT", "t": "TERMINAL"})
let s:line_statusline_enable = get(g:, 'line_statusline_enable', 1)
let s:line_tabline_enable = get(g:, 'line_tabline_enable', 1)
let s:line_tabline_show_pwd = get(g:, 'line_tabline_show_pwd', 1)
let s:line_modi_mark = get(g:, 'line_modi_mark', '+')
let s:line_dclick_interval = get(g:, 'line_dclick_interval', 100)
let s:line_statusline_getters = get(g:, 'line_statusline_getters', [])
let s:line_unnamed_filename = get(g:, 'line_unnamed_filename', '[unnamed]')
let s:line_powerline_enable = get(g:, 'line_powerline_enable', 0)

hi VimLine_Space ctermbg=NONE
hi VimLine_Head ctermbg=24
hi VimLine_C ctermbg=25
hi VimLine_NC ctermbg=238

hi VimLine_NC_Break ctermbg=238 ctermfg=242

hi VimLine_Head_C_R ctermfg=24 ctermbg=25
hi VimLine_Head_NC_R ctermfg=24 ctermbg=238

hi VimLine_C_NC_R ctermfg=25 ctermbg=238
hi VimLine_NC_C_R ctermfg=238 ctermbg=25

hi VimLine_C_Space_R ctermfg=25 ctermbg=NONE
hi VimLine_NC_Space_R ctermfg=238 ctermbg=NONE

hi VimLine_Head_Space_R ctermfg=24 ctermbg=NONE

augroup lines
    au!
    if s:line_statusline_enable == 1
        set laststatus=2
        setglobal statusline=%!SetStatusline()
        au BufEnter,WinEnter * call RefreshStatusline()
    endif
    if s:line_tabline_enable == 1
        set showtabline=2
        let g:tabline_head = s:line_tabline_show_pwd ? substitute($PWD, '\v(.*/)*', '', 'g') : 'BUFFER'
        au BufEnter,BufWritePost,TextChanged,TextChangedI * call SetTabline()
    endif
augroup END

func! SetTabline(...)
    let infos = []
    let [buflist, l, r] = s:get_buf_list()

    call add(infos, { 'hl': 'VimLine_Head', 'text': ' %{g:tabline_head} ' })
    call add(infos, { 'hl': buflist[0].iscurrent ? 'VimLine_Head_C_R' :  'VimLine_Head_NC_R', 'text': '' })
    call add(infos, { 'text': '%<' })

    let bi = 1
    for bufinfo in buflist
        call add(infos, { 'hl': bufinfo.iscurrent ? 'VimLine_C' : 'VimLine_NC', 'text': printf(' %s ', bufinfo.name), 'nr': bufinfo.nr })

        if bufinfo == buflist[-1]
            let breakinfo = ''
            let breakhl = bufinfo.iscurrent ? 'VimLine_C_Space_R' : 'VimLine_NC_Space_R'
        else
            if bufinfo.iscurrent == buflist[bi].iscurrent
                let breakinfo = ''
                let breakhl = 'VimLine_NC_Break'
            else
                let breakinfo = ''
                let breakhl = bufinfo.iscurrent ? 'VimLine_C_NC_R' : 'VimLine_NC_C_R'
            endif
        endif

        call add(infos, { 'hl': breakhl, 'text': breakinfo })

        let bi += 1
    endfor

    let bufferswidth = &columns - strwidth(g:tabline_head) - 3
    let infos = infos[:1] + s:hide_infos_by_column(infos[2:], l, r, bufferswidth)

    call add(infos, { 'hl': 'VimLine_Space'})

    let tabline = ''
    for info in infos
        let tabline .= s:info_to_text(info)
    endfor
    let &tabline = tabline
endf

func! RefreshStatusline()
    for wininfo in getwininfo()
        if wininfo.winnr == winnr()
            setlocal statusline<
        else
            call setwinvar(wininfo.winnr, '&statusline', printf('%'. (wininfo.width) .'s', ''))
        endif
    endfor
endf

func! SetStatusline(...)
    let infos = []
    call add(infos, { 'hl': 'VimLine_Head', 'text': ' %{g:line_mode_map[mode()]} ' })
    call add(infos, { 'hl': len(s:line_statusline_getters) ? 'VimLine_Head_NC_R' : 'VimLine_Head_Space_R', 'text': '' })

    let hi = 0
    for getter in s:line_statusline_getters
        call add(infos, { 'hl': 'VimLine_NC', 'text': '%{'.getter.'()}' })

        if getter == s:line_statusline_getters[-1]
            let breakinfo = ''
            let breakhl = 'VimLine_NC_Space_R'
        else
            let breakinfo = ''
            let breakhl = 'VimLine_NC_Break'
        endif

        call add(infos, { 'hl': breakhl, 'text': breakinfo })

        let hi += 1
    endfor
    call add(infos, { 'hl': 'VimLine_Space' })
    call add(infos, { 'text': '%=' })
    call add(infos, { 'hl': 'VimLine_NC_Space_R', 'text': '' })
    call add(infos, { 'hl': 'VimLine_NC', 'text': ' %{GetPathName()} ' })
    call add(infos, { 'hl': 'VimLine_Head_NC_R', 'text': '' })
    call add(infos, { 'hl': 'VimLine_Head', 'text': '%4P %L %l %v ' })
    call add(infos, { 'hl': 'VimLine_Space' })

    let statusline = ''
    for info in infos
        let statusline .= s:info_to_text(info)
    endfor
    return statusline
endf

func! Clicktab(minwid, clicks, button, modifiers) abort
    let l:timerID = get(s:, 'clickTabTimer', 0)
    if a:clicks == 1 && a:button is# 'l'
        if l:timerID == 0
            let s:clickTabTimer = timer_start(100, 'SwitchTab')
            let l:timerID = s:clickTabTimer
        endif
    elseif a:clicks == 2 && a:button is# 'l'
        silent execute 'bd' a:minwid
        let s:clickTabTimer = 0
        call timer_stop(l:timerID)
        call SetTabline()
    endif
    let s:minwid = a:minwid
    let s:timerID = l:timerID
    func! SwitchTab(...)
        silent execute 'buffer' s:minwid
        let s:clickTabTimer = 0
        call timer_stop(s:timerID)
    endf
endf

func! GetPathName()
    let l:name = substitute(expand('%'), $PWD . '/', '', '')
    let l:name = substitute(l:name, $HOME, '~', '')
    let l:name = len(l:name) ? l:name : s:line_unnamed_filename
    return l:name
endf

func! s:get_buf_list()
    let buflist = []
    let [l, r] = [0, 0]
    let i = 1
    while i <= bufnr('$')
        if bufexists(i) && buflisted(i)
            let l:name = (len(fnamemodify(bufname(i), ':t')) ? fnamemodify(bufname(i), ':t') : s:line_unnamed_filename) . (getbufvar(i, '&mod') ? s:line_modi_mark : '')
            call add(buflist, { 'nr': i, 'name': name, 'iscurrent': i == bufnr('%') })
            let l += i < bufnr('%')
            let r += i > bufnr('%')
        endif
        let i += 1
    endwhile
    return [buflist, l, r]
endf

func! s:hide_infos_by_column(infos, l, r, columns)
    let [infos, l, r] = [a:infos, a:l, a:r]
    let [lhidecount, rhidecount] = [0, 0]
    while 1
        let ltext = lhidecount ? printf(' %d_< ', lhidecount / 2) : ''
        let rtext = rhidecount ? printf(' >_%d ', rhidecount / 2) : ''
        let width = s:get_infos_text_width(infos[lhidecount : -rhidecount - 1])
        let width += lhidecount ? strwidth(ltext) + 1 : 0
        let width += rhidecount ? strwidth(rtext) + 1 : 0
        if a:columns > width | break | endif
        if l - lhidecount >= r - rhidecount | let lhidecount += 2 | else | let rhidecount += 2 | endif
    endwhile

    if rhidecount
        let infos = infos[:-rhidecount - 1]
        call add(infos, { 'hl': 'VimLine_NC', "text": rtext})
        call add(infos, { 'hl': 'VimLine_NC_Space_R', 'text': '' })
    endif

    if lhidecount
        let infos = [{ 'hl': 'VimLine_NC', "text": ltext}] + infos[lhidecount:]
    endif

    return infos
endf

" type Info = { 'hl': string, 'text': string, 'nr': number }[]
func! s:info_to_text(info)
    let info = a:info
    if s:line_powerline_enable == 0 && exists('info.text') && index(['', '', '', ''], info.text) != -1
        let info.text = ' '
        let info.hl = 'VimLine_Space'
    endif
    let text = ''
    let text .= exists('info.nr') ? '%' . info.nr . '@Clicktab@' : ''
    let text .= exists('info.hl') ? '%#' . info.hl . '#' : ''
    let text .= exists('info.text') ? info.text : ''
    let text .= exists('info.nr') ? '%X' : ''
    return text
endf

func! s:get_infos_text_width(infos)
    let width = 0
    for info in a:infos
        if exists('info.text')
            let width += strwidth(info.text)
        endif
    endfor
    return width
endf
