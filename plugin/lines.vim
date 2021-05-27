if exists('s:loaded') | finish | endif
let s:loaded = 1

let g:line_mode_map=get(g:, 'line_mode_map', { "n": "NORMAL", "v": "VISUAL", "V": "V-LINE", "\<c-v>": "V-CODE", "i": "INSERT", "R": "R", "r": "R", "Rv": "V-REPLACE", "c": "CMD-IN", "s": "SELECT", "S": "SELECT", "\<c-s>": "SELECT", "t": "TERMINAL"})
let s:line_statusline_enable = get(g:, 'line_statusline_enable', 1)
let s:line_tabline_enable = get(g:, 'line_tabline_enable', 1)
let s:line_tabline_show_pwd = get(g:, 'line_tabline_show_pwd', 1)
let s:line_modi_mark = get(g:, 'line_modi_mark', '+')
let s:line_pwd_suffix = get(g:, 'line_pwd_suffix', '/')
let s:line_dclick_interval = get(g:, 'line_dclick_interval', 100)
let s:line_statusline_getters = get(g:, 'line_statusline_getters', [])
let s:line_unnamed_filename = get(g:, 'line_unnamed_filename', '[unnamed]')

hi VimLineHead ctermbg=24
hi VimLineSpace ctermbg=NONE
hi VimTabC ctermbg=25
hi VimTabNC ctermbg=238

augroup lines
    au!
    if s:line_statusline_enable == 1
        set laststatus=2
        setglobal statusline=%!SetStatusline()
        au BufEnter,WinEnter * call RefreshStatusline()
    endif
    if s:line_tabline_enable == 1
        set showtabline=2
        let g:tabline_head = s:line_tabline_show_pwd ? substitute($PWD, '\v(.*/)*', '', 'g') . s:line_pwd_suffix : 'BUFFER'
        au BufEnter,BufWritePost,TextChanged,TextChangedI * call SetTabline()
    endif
augroup END

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
    let statusline = '%#VimLineHead# %{g:line_mode_map[mode()]} %#VimLineSpace#'
    for getter in s:line_statusline_getters
        let statusline .= ' %#VimTabNC#%{'.getter.'()}%#VimLineSpace#'
    endfor
    let statusline .= '%=%#VimLineHead# %{GetPathName()} %#VimLineSpace# %#VimLineHead# %4P %L %l %v %#VimLineSpace#'
    return statusline
endf

func! SetTabline(...)
    let tabline = '%#VimLineHead# %{g:tabline_head} %#VimLineSpace#'
    let [buflist, l, r] = s:get_buf_list()
    let [ls, rs] = [0, 0]
    while 1
        let [lt, rt] = [ls ? printf(' %d_< ', ls) : '', rs ? printf(' >_%d ', rs) : '']
        if &columns > s:get_buftext_width(buflist[ls : -rs - 1]) + strwidth(g:tabline_head) + 3 + strwidth(lt . rt) | break | endif
        if [l, r] == [0, 0] | break | endif
        if l - ls >= r - rs | let ls += 1 | else | let rs += 1 | endif
    endwhile
    let tabline .= ls ? ' %#VimTabNC#' . lt . '%#VimLineSpace#' : ''
    for bufinfo in buflist[ls : -rs - 1]
        let tabline .= '%' . bufinfo.nr . '@Clicktab@'
        let tabline .= bufinfo.nr == bufnr('%') ? ' %#VimTabC# ' : ' %#VimTabNC# '
        let tabline .= bufinfo.name . ' %#VimLineSpace#%X'
    endfor
    let tabline .= rs ? '%#VimLineSpace# %#VimTabNC#' . rt . '%#VimLineSpace#' : ''
    let &tabline = tabline
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

func! s:get_buftext_width(buflist)
    let width = 0
    if len(a:buflist) == 0
        return width
    endif
    for binfo in a:buflist
        let width += strwidth(binfo.name) + 3
    endfor
    return width - 1
endf
