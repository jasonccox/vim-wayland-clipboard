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

" The '+' register doesn't work for yanking if:
" - vim was built without 'clipboard'.
" - x11 / xwayland is unavailable.
" (https://github.com/vim/vim/blob/93197fde0f1db09b1e495cf3eb14a8f42c318b80/src/register.c#L247)
"
" My solution is to map '"+' to '"w' and send the 'w' register to the
" Wayland clipboard as well.
"
" This variable controls whether '"+' gets mapped to '"w'. It's on by default
" if the 'clipboard' feature isn't available, or if $DISPLAY isn't set,
" but the user can turn it off always if desired.
let s:plus_to_w = (!has('clipboard') || empty($DISPLAY)) && !exists('g:wayland_clipboard_no_plus_to_w')

" remap '"+' to '"w' -- this will only apply to yanking since '"+p' and '"+P'
" are also remapped below
if s:plus_to_w
    nnoremap "+ "w
    vnoremap "+ "w
endif

let s:copy_args = exists('g:wayland_clipboard_copy_args') ? g:wayland_clipboard_copy_args : []

function! s:unnamedplus()
    return &clipboard =~ 'unnamedplus'
        \ || (exists('g:wayland_clipboard_unnamedplus') && g:wayland_clipboard_unnamedplus)
endfunction

" pass register contents to wl-copy if the '+' (or 'w') register was used
function! s:WaylandYank()
    if v:event['regname'] == '+' ||
                \ (v:event['regname'] == 'w' && s:plus_to_w) ||
                \ (v:event['regname'] == '' && s:unnamedplus())
        let job = job_start(['wl-copy'] + s:copy_args, {
            \   "in_io": "pipe", "out_io": "null", "err_io": "null",
            \   "stoponexit": "",
            \ })
        call ch_sendraw(job, getreg(v:event['regname']))
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

let s:paste_args = exists('g:wayland_clipboard_paste_args') ? g:wayland_clipboard_paste_args : []
let s:paste_args_str = empty(s:paste_args) ? '' : ' ' . join(s:paste_args)

function! s:clipboard_to_unnamed()
    silent let @"=substitute(system('wl-paste --no-newline' . s:paste_args_str), "\r", '', 'g')
endfunction

function! s:put(p, fallback)
    if a:fallback
        return a:p
    endif

    call s:clipboard_to_unnamed()
    return '""' . a:p
endfunction

function! s:ctrl_r(cr)
    call s:clipboard_to_unnamed()
    return a:cr . '"'
endfunction

nnoremap <expr> <silent> "+p <SID>put('p', v:false)
nnoremap <expr> <silent> "+P <SID>put('P', v:false)
nnoremap <expr> <silent> p <SID>put('p', !<SID>unnamedplus())
nnoremap <expr> <silent> P <SID>put('P', !<SID>unnamedplus())

vnoremap <expr> <silent> "+p <SID>put('p', v:false)
vnoremap <expr> <silent> "+P <SID>put('P', v:false)
vnoremap <expr> <silent> p <SID>put('p', !<SID>unnamedplus())
vnoremap <expr> <silent> P <SID>put('P', !<SID>unnamedplus())

inoremap <expr> <silent> <C-R>+ <SID>ctrl_r("\<C-R>")
inoremap <expr> <silent> <C-R><C-R>+ <SID>ctrl_r("\<C-R>\<C-R>")
inoremap <expr> <silent> <C-R><C-O>+ <SID>ctrl_r("\<C-R>\<C-O>")
inoremap <expr> <silent> <C-R><C-P>+ <SID>ctrl_r("\<C-R>\<C-P>")

" }}}

" vim:foldmethod=marker:foldlevel=0
