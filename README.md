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
