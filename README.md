# tmux configuration

Minimal tmux configuration focused on:
- vim-style copy-mode
- reliable clipboard support over SSH / WSL
- zero plugins, explicit behavior

## Design goals

This setup is intentionally small and explicit.

- **tmux handles workflow**, not files
- **nvim handles editing**
- Clipboard handling is done via **OSC 52**, not X11/Wayland tooling

The goal is consistent behavior:
- locally
- over SSH
- in WSL
- without relying on `xclip`, `wl-copy`, or desktop-specific clipboard tools

## Clipboard

Copying from tmux uses **OSC 52 escape sequences**, sent directly to the terminal.

This matches the clipboard approach used in my Neovim configuration
(`:CopyOSC`) and ensures the same behavior across environments.

Implementation details:
- `osc52-copy.sh` reads stdin
- base64-encodes the content
- sends an OSC 52 sequence to the terminal

The terminal emulator (e.g. WezTerm or Windows Terminal) is responsible
for placing the content in the system clipboard.

## Terminal requirements

This setup requires a terminal emulator with **OSC 52 support**.

If the terminal does not support OSC 52 (or has it disabled),
clipboard integration from tmux will not work.

## Usage

- Enter copy-mode: `Ctrl-b [`
- Line-wise selection: `V`
- Yank to system clipboard: `y`

## Loading

This directory is the canonical source.

`~/.tmux.conf` should only contain:

```tmux
source-file ~/dev/env/terminal/tmux/tmux.conf
````

## Non-goals

* No plugins
* No session persistence
* No automatic layouts or keybinding remaps

Additional behavior is added only when real friction appears.

## TODO

* Map capslock to ctrl, but this may be done on OS level instead
