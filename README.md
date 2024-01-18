# vim-wayland-clipboard

**[jasoncarloscox.com/creations/vim-wayland-clipboard](https://jasoncarloscox.com/creations/vim-wayland-clipboard/)**

This plugin allows Vim to integrate with the Wayland clipboard when using the `+` register. This means you can yank text into the `+` register and paste it in other Wayland programs, or copy text in other Wayland programs and paste it in Vim from the `+` register. Operators and counts work, too!

When running Vim outside of Wayland, the `+` register continues to work as normal.

## Requirements

For this plugin to work, you need [wl-clipboard](https://github.com/bugaevc/wl-clipboard) installed, and Vim must be compiled with the `+eval` feature.

## Installation

Use Vim8's built-in packages:

1. `mkdir -p ~/.vim/pack/vim-wayland-clipboard/start/`
2. `git clone https://github.com/jasonccox/vim-wayland-clipboard.git ~/.vim/pack/vim-wayland-clipboard/start/vim-wayland-clipboard`

## Usage and Features

Just use `"+y`, `"+p`, `<C-R>+`, and friends as you always do. Specifically, here's what's supported:

- Any yank command that starts with `"+` (e.g. `"+yy` or `"+yiw`) in insert and visual modes.
- Pasting in normal and visual modes with `"+p` or `"+P`.
- Pasting in insert mode with `<C-R>+`, `<C-R><C-R>+`, `<C-R><C-O>+`, or `<C-R><C-P>+`.
- Yanking and pasting (`p` and `P` in normal and visual modes) with `clipboard=unnamedplus`.

If you need more functionality, consider checking out [vim-fakeclip](https://github.com/kana/vim-fakeclip).

## Notes

### Passing extra arguments to `wl-copy` or `wl-paste`

If you want to pass extra arguments to `wl-copy`, set `g:wayland_clipboard_copy_args` to a list of strings, one per argument. For example, to copy to the primary clipboard and only allow the contents to be pasted once, you could do the following:

```vimscript
let g:wayland_clipboard_copy_args = ['--primary', '--paste-once']
```

To pass extra arguments to `wl-paste`, use `g:wayland_clipboard_paste_args` in the same way.

### Clobbering the `w` Register

On Vim builds without `clipboard`, or if Xwayland isn't running, the `+` register doesn't work for yanking. My solution is to map `"+` to `"w` and send the `w` register to the Wayland clipboard as well. (This only occurs when the `clipboard` feature is missing or the X `$DISPLAY` environment vairable is empty.) If you use the `w` register for other things and don't want it to clobber your system clipboard, put `let g:wayland_clipboard_no_plus_to_w = 1` in your `vimrc` to disable this feature.

### Non-recursive Mappings

This plugin uses mappings of `"+p`, `<C-R>+`, `"+`, etc. to do its job. As a result, it won't work with existing *non-recursive* mappings that run these commands, e.g. `nnoremap <Leader>p "+p`. If you have mappings like these, you'll need to use their recursive counterparts instead for the plugin to work.

## Contributing

Contributions are welcome! You can send questions, bug reports, patches, etc. by email to [~jcc/public-inbox@lists.sr.ht](https://lists.sr.ht/~jcc/public-inbox). (Don't know how to contribute via email? Check out the interactive tutorial at [git-send-email.io](https://git-send-email.io), or [email me](mailto:me@jasoncarloscox.com) for help.)

GitHub issues and pull requests are fine, too.
