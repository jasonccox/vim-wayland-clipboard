" wayland-clipboard.vim - Integrate with Wayland's clipboard when using the '+'
" register. Requires wl-clipboard and the +eval and +clipboard Vim features.
"
" This script was inspired by
" https://www.reddit.com/r/Fedora/comments/ax9p9t/vim_and_system_clipboard_under_wayland/
" but uses an autocmd to allow yanking with operators to work.

" only load this script once
if exists('g:loaded_wayland_clipboard')
    finish
endif
let g:loaded_wayland_clipboard = 1

" only run this on Wayland
if empty($WAYLAND_DISPLAY)
    finish
endif

" pass register contents to wl-copy if the '+' register was used
function! s:WaylandYank()
    if v:event['regname'] == '+'
        call system("wl-copy", getreg(v:event['regname']))
    endif 
endfunction

" run s:WaylandYank() after every time text is yanked
augroup waylandyank
    autocmd!
    autocmd TextYankPost * call s:WaylandYank()
augroup END

" remap paste commands to first pull in clipboard contents with wl-paste
nnoremap "+p :<C-U>let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g') \| exec 'normal! ' . v:count1 . 'p'<cr>
nnoremap "+P :<C-U>let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g') \| exec 'normal! ' . v:count1 . 'P'<cr>
