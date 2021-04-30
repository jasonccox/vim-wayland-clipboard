# vim-wayland-clipboard

This plugin allows Vim to integrate with the Wayland clipboard when using the `+` register. This means you can yank text into the `+` register and paste it in other Wayland programs, or copy text in other Wayland programs and paste it in Vim from the `+` register. Operators and counts work, too!

When running Vim outside of Wayland, the `+` register continues to work as normal.

## Requirements

For this plugin to work, you need [wl-clipboard](https://github.com/bugaevc/wl-clipboard) installed, and Vim must be compiled with the `+eval` feature.

## Installation

Use Vim8's built-in packages:

1. `mkdir -p ~/.vim/pack/vim-wayland-clipboard/start/`
2. `git clone https://github.com/jasonccox/vim-wayland-clipboard.git ~/.vim/pack/vim-wayland-clipboard/start/vim-wayland-clipboard`

## Usage

Just use `"+y`, `"+p`, and friends as you always do.

## Notes

On Vim builds without `clipboard`, the `+` register doesn't work for yanking. My solution is to map `"+` to `"w` and send the `w` register to the Wayland clipboard as well. (This only occurs when the `clipboard` feature is missing.) If you use the `w` register for other things and don't want it to clobber your system clipboard, put `let g:wayland_clipboard_no_plus_to_w = 1` in your `vimrc` to disable this feature.
