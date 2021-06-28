let g:line_mode_map=get(g:, 'line_mode_map', { "n": "NORMAL", "v": "VISUAL", "V": "V-LINE", "\<c-v>": "V-CODE", "i": "INSERT", "R": "R", "r": "R", "Rv": "V-REPLACE", "c": "CMD-IN", "s": "SELECT", "S": "SELECT", "\<c-s>": "SELECT", "t": "TERMINAL"})
let s:line_modi_mark = get(g:, 'line_modi_mark', '+')
let s:line_dclick_interval = get(g:, 'line_dclick_interval', 100)
let s:line_statusline_getters = get(g:, 'line_statusline_getters', [])
let s:line_unnamed_filename = get(g:, 'line_unnamed_filename', '[unnamed]')
let s:line_powerline_enable = get(g:, 'line_powerline_enable', 0)

func! lines#refresh_statusline()
    for wininfo in getwininfo()
        if wininfo.winnr == winnr()
            setlocal statusline<
        else
            call setwinvar(wininfo.winnr, '&statusline', '%#VimLine_Dark#' . printf('%'. (wininfo.width) .'s', ''))
        endif
    endfor
endf

func! lines#set_statusline(...)
    let infos = []
    call add(infos, { 'hl': 'VimLine_Light', 'text': ' %{g:line_mode_map[mode()]} ' })
    call add(infos, { 'hl': len(s:line_statusline_getters) ? 'VimLine_Light_Dark' : 'VimLine_Light_None', 'text': '' })

    let hi = 0
    for getter in s:line_statusline_getters
        call add(infos, { 'hl': 'VimLine_Dark', 'text': '%{'.getter.'()}' })

        if getter == s:line_statusline_getters[-1]
            let breakinfo = ''
            let breakhl = 'VimLine_Dark_None'
        else
            let breakinfo = ''
            let breakhl = 'VimLine_Dark_Break'
        endif

        call add(infos, { 'hl': breakhl, 'text': breakinfo })

        let hi += 1
    endfor
    call add(infos, { 'hl': 'VimLine_None' })
    call add(infos, { 'text': '%=' })
    call add(infos, { 'hl': 'VimLine_Dark_None', 'text': '' })
    call add(infos, { 'hl': 'VimLine_Dark', 'text': ' %{lines#get_pathname()} ' })
    call add(infos, { 'hl': 'VimLine_Light_Dark', 'text': '' })
    call add(infos, { 'hl': 'VimLine_Light', 'text': '%4P %L %l %v ' })
    call add(infos, { 'hl': 'VimLine_None' })

    let statusline = ''
    for info in infos
        let statusline .= s:info_to_text(info)
    endfor
    return statusline
endf

func! lines#set_tabline(...)
    let headinfos = []
    let [buflist, l, r] = s:get_buf_list()
    let isfirst = len(buflist) && buflist[0].iscurrent

    call add(headinfos, { 'hl': 'VimLine_Light', 'text': ' %{g:tabline_dir} ' })
    call add(headinfos, isfirst ? { 'hl': 'VimLine_Light_Break', 'text': '' } : { 'hl': 'VimLine_Light_Dark', 'text': '' })
    call add(headinfos, { 'text': '%<' })

    let bufinfos = []

    let bi = 1
    for bufinfo in buflist
        call add(bufinfos, { 'hl': bufinfo.iscurrent ? 'VimLine_Light' : 'VimLine_Dark', 'text': printf(' %s ', bufinfo.name), 'nr': bufinfo.nr })

        if bufinfo == buflist[-1]
            let breakinfo = ''
            let breakhl = bufinfo.iscurrent ? 'VimLine_Light_None' : 'VimLine_Dark_None'
        else
            if bufinfo.iscurrent == buflist[bi].iscurrent
                let breakinfo = ''
                let breakhl = 'VimLine_Dark_Break'
            else
                let breakinfo = ''
                let breakhl = bufinfo.iscurrent ? 'VimLine_Light_Dark' : 'VimLine_Dark_Light'
            endif
        endif

        call add(bufinfos, { 'hl': breakhl, 'text': breakinfo })

        let bi += 1
    endfor

    let bufferswidth = &columns - strwidth(g:tabline_dir) - 3
    let bufinfos = s:hide_bufinfos(bufinfos, l, r, bufferswidth)

    let infos = headinfos + bufinfos + [{ 'hl': 'VimLine_None'}]

    let tabline = ''
    for info in infos
        let tabline .= s:info_to_text(info)
    endfor
    let &tabline = tabline
endf

func! lines#clicktab(minwid, clicks, button, modifiers) abort
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
        call lines#set_tabline()
    endif
    let s:minwid = a:minwid
    let s:timerID = l:timerID
    func! SwitchTab(...)
        silent execute 'buffer' s:minwid
        let s:clickTabTimer = 0
        call timer_stop(s:timerID)
    endf
endf

func! lines#get_pathname()
    let l:name = substitute(expand('%'), $PWD . '/', '', '')
    let l:name = substitute(l:name, $HOME, '~', '')
    let l:name = len(l:name) ? l:name : s:line_unnamed_filename
    return nerdfont#get_fileicon(&ft, bufname('%')) . l:name
endf

func! s:get_buf_list()
    let buflist = []
    let [l, r] = [0, 0]
    let i = 1
    while i <= bufnr('$')
        if bufexists(i) && buflisted(i)
            let l:name = nerdfont#get_fileicon(getbufvar(i, '&ft'), bufname(i))
            let l:name .= (len(fnamemodify(bufname(i), ':t')) ? fnamemodify(bufname(i), ':t') : s:line_unnamed_filename) . (getbufvar(i, '&mod') ? s:line_modi_mark : '')
            call add(buflist, { 'nr': i, 'name': name, 'iscurrent': i == bufnr('%') })
            let l += i < bufnr('%')
            let r += i > bufnr('%')
        endif
        let i += 1
    endwhile
    return [buflist, l, r]
endf

func! s:hide_bufinfos(bufinfos, l, r, columns)
    let [bufinfos, l, r] = [a:bufinfos, a:l, a:r]

    " 计算需要隐藏的块的数量
    let [lhidecount, rhidecount] = [0, 0]
    while 1
        let ltext = lhidecount ? ' … ' : ''
        let rtext = rhidecount ? ' … ' : ''
        let width = s:get_infos_text_width(bufinfos[2 * lhidecount : -2 * rhidecount - 1])
        let width += lhidecount ? strwidth(ltext) + 1 : 0
        let width += rhidecount ? strwidth(rtext) + 1 : 0
        if a:columns > width | break | endif
        if l - lhidecount >= r - rhidecount | let lhidecount += 1 | else | let rhidecount += 1 | endif
    endwhile

    " 有隐藏内容 去掉末尾 
    if lhidecount || rhidecount
        let bufinfos = bufinfos[:len(bufinfos)-2]
    endif

    " 左右都隐藏
    if lhidecount && rhidecount
        let bufinfos =
            \ [{ 'hl': 'VimLine_Dark', "text": ltext}, { 'hl': 'VimLine_Dark_Break', 'text': '' }] +
            \ bufinfos[2 * lhidecount:-2 * rhidecount] +
            \ [{ 'hl': 'VimLine_Dark', "text": rtext}]

        let emptywidth = a:columns - s:get_infos_text_width(bufinfos)
        let leftinfo = a:bufinfos[2 * lhidecount - 2]
        let rightinfo = a:bufinfos[-2 * rhidecount]
        let pretext = bufinfos[0].text
        let bufinfos[0].text = ' …' . s:get_str_bycount(leftinfo.text, -emptywidth - 1)
        let bufinfos[0].nr = leftinfo.nr

        let emptywidth = emptywidth + strwidth(pretext) - strwidth(bufinfos[0].text)
        let pretext = bufinfos[-1].text
        let bufinfos[-1].text = s:get_str_bycount(rightinfo.text, emptywidth + 1) . '… '
        let bufinfos[-1].nr = rightinfo.nr

        let emptywidth = emptywidth + strwidth(pretext) - strwidth(bufinfos[-1].text)
        if emptywidth > 0
            let bufinfos[0].text = s:get_str_bycount(bufinfos[0].text, -(strwidth(bufinfos[0].text) - 1))
            while emptywidth > 0
                let emptywidth -= 1
                let bufinfos[0].text = '…' . bufinfos[0].text
            endwhile
            let bufinfos[0].text = ' ' . bufinfos[0].text
        endif
    endif

    " 只有左边隐藏
    if lhidecount && !rhidecount
        let bufinfos =
            \ [{ 'hl': 'VimLine_Dark', "text": ltext}, { 'hl': 'VimLine_Dark_Break', 'text': '' }] +
            \ bufinfos[2 * lhidecount:]

        let emptywidth = a:columns - s:get_infos_text_width(bufinfos)
        let leftinfo = a:bufinfos[2 * lhidecount - 2]
        let pretext = bufinfos[0].text
        let bufinfos[0].text = ' …' . s:get_str_bycount(leftinfo.text, -emptywidth - 1)
        let bufinfos[0].nr = leftinfo.nr

        let emptywidth = emptywidth + strwidth(pretext) - strwidth(bufinfos[0].text)
        if emptywidth > 0
            let bufinfos[0].text = s:get_str_bycount(bufinfos[0].text, -(strwidth(bufinfos[0].text) - 1))
            while emptywidth > 0
                let emptywidth -= 1
                let bufinfos[0].text = '…' . bufinfos[0].text
            endwhile
            let bufinfos[0].text = ' ' . bufinfos[0].text
        endif
    endif

    " 只有右边隐藏
    if !lhidecount && rhidecount
        let bufinfos =
            \ bufinfos[:-2 * rhidecount] +
            \ [{ 'hl': 'VimLine_Dark', "text": rtext}]

        let emptywidth = a:columns - s:get_infos_text_width(bufinfos)
        let rightinfo = a:bufinfos[-2 * rhidecount]
        let pretext = bufinfos[-1].text
        let bufinfos[-1].text = s:get_str_bycount(rightinfo.text, emptywidth + 1) . '… '
        let bufinfos[-1].nr = rightinfo.nr

        let emptywidth = emptywidth + strwidth(pretext) - strwidth(bufinfos[-1].text)
        if emptywidth > 0
            let bufinfos[-1].text = s:get_str_bycount(bufinfos[-1].text, strwidth(bufinfos[-1].text) - 1)
            while emptywidth > 0
                let emptywidth -= 1
                let bufinfos[-1].text .= '…'
            endwhile
            let bufinfos[-1].text .= ' '
        endif
    endif

    return bufinfos
endf

func! s:info_to_text(info)
    let info = a:info
    if s:line_powerline_enable == 0 && exists('info.text') && index(['', '', '', ''], info.text) != -1
        let info.text = ' '
        let info.hl = 'VimLine_None'
    endif
    let text = ''
    let text .= exists('info.nr') ? '%' . info.nr . '@lines#clicktab@' : ''
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

func! s:get_str_bycount(str, l)
    if a:l > 0
        return strcharpart(a:str, 0, a:l)
    else
        let str = ''
        let i = 0
        let sindex = strwidth(a:str) - 1
        while i < -a:l
            let c = strcharpart(a:str, sindex, 1)
            let str = (len(c) ? c : '') . str
            let i += 1
            let sindex -= 1
        endwhile
        return str
    endif
endf
