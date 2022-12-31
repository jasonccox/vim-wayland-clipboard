" wayland-clipboard.vim - Integrate with Wayland's clipboard when using the '+'
" register. Requires wl-clipboard and the +eval and +clipboard Vim features.
"
" This script was inspired by
" https://www.reddit.com/r/Fedora/comments/ax9p9t/vim_and_system_clipboard_under_wayland/
" but uses an autocmd to allow yanking with operators to work.

" Early exit checks {{{

" only load this script once
if exists('g:loaded_wayland_clipboard')
    finish
endif
let g:loaded_wayland_clipboard = 1

" only run this in Vim on Wayland -- Vim on X has native clipboard support,
" and Neovim already works with wl-copy by default
if has('nvim') || empty($WAYLAND_DISPLAY)
    finish
endif

" }}}

" Yanking {{{

" On Vim builds without 'clipboard', the '+' register doesn't work for
" yanking. My solution is to map '"+' to '"w' and send the 'w' register to the
" Wayland clipboard as well.
"
" This variable controls whether '"+' gets mapped to '"w'. It's on by default
" if the 'clipboard' feature isn't available, but the user can turn it off
" always if desired.
let s:plus_to_w = !has('clipboard') && !exists('g:wayland_clipboard_no_plus_to_w')

" remap '"+' to '"w' -- this will only apply to yanking since '"+p' and '"+P'
" are also remapped below
if s:plus_to_w
    nnoremap "+ "w
    vnoremap "+ "w
endif

" pass register contents to wl-copy if the '+' (or 'w') register was used
function! s:WaylandYank()
    if v:event['regname'] == '+' || (v:event['regname'] == 'w' && s:plus_to_w)
        silent call job_start(['wl-copy', '--', getreg(v:event['regname'])], {
            \   "in_io": "null", "out_io": "null", "err_io": "null",
            \   "stoponexit": "",
            \ })
    endif
endfunction

" run s:WaylandYank() after every time text is yanked
augroup waylandyank
    autocmd!
    autocmd TextYankPost * call s:WaylandYank()
augroup END

" }}}

" Pasting {{{

" remap paste commands to first pull in clipboard contents with wl-paste
let prepaste = "silent let @\"=substitute(system('wl-paste --no-newline'), \"\\r\", '', 'g')"

for p in ['p', 'P']
    execute "nnoremap <silent> \"+" . p . " :<C-U>" . prepaste . " \\| exec 'normal! ' . v:count1 . '" . p . "'<CR>"
endfor

for cr in ['<C-R>', '<C-R><C-R>', '<C-R><C-O>', '<C-R><C-P>']
    execute "inoremap <silent> " . cr . "+ <C-O>:<C-U>" . prepaste . "<CR>" . cr . "\""
endfor

" }}}

" vim:foldmethod=marker:foldlevel=0
