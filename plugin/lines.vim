if exists('s:loaded') | finish | endif
let s:loaded = 1

let s:line_statusline_enable = get(g:, 'line_statusline_enable', 1)
let s:line_tabline_enable = get(g:, 'line_tabline_enable', 1)
let s:line_tabline_show_pwd = get(g:, 'line_tabline_show_pwd', 1)
let s:line_hl = get(g:, 'line_hl', { 'none': 'NONE', 'light': '24', 'dark': '238', 'break': '244' })

exec printf('hi VimLine_None        ctermbg=%s', s:line_hl.none)
exec printf('hi VimLine_Light       ctermbg=%s', s:line_hl.light)
exec printf('hi VimLine_Dark        ctermbg=%s', s:line_hl.dark)
exec printf('hi VimLine_Light_Dark  ctermfg=%s ctermbg=%s', s:line_hl.light, s:line_hl.dark)
exec printf('hi VimLine_Dark_Light  ctermfg=%s ctermbg=%s', s:line_hl.dark, s:line_hl.light)
exec printf('hi VimLine_Light_None  ctermfg=%s ctermbg=%s', s:line_hl.light, s:line_hl.none)
exec printf('hi VimLine_Dark_None   ctermfg=%s ctermbg=%s', s:line_hl.dark, s:line_hl.none)
exec printf('hi VimLine_Light_Break ctermbg=%s ctermfg=%s', s:line_hl.light, s:line_hl.break)
exec printf('hi VimLine_Dark_Break  ctermbg=%s ctermfg=%s', s:line_hl.dark, s:line_hl.break)

augroup lines
    au!
    if s:line_statusline_enable == 1
        set laststatus=2
        setglobal statusline=%!lines#set_statusline()
        au BufEnter,WinEnter * call lines#refresh_statusline()
    endif
    if s:line_tabline_enable == 1
        set showtabline=2
        let g:tabline_Light = s:line_tabline_show_pwd ? nerdfont#get_diricon() . substitute($PWD, '\v(.*/)*', '', 'g') : 'BUFFER'
        au BufEnter,BufWritePost,TextChanged,TextChangedI * call lines#set_tabline()
    endif
augroup END
