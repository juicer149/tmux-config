# tmux environment

This repository contains the canonical tmux configuration used in my
development environment.

It is deliberately small, explicit, and procedural.

tmux is treated here as an **execution and workflow orchestrator** —
not a shell framework, not an editor extension, and not a stateful system.

---

## Architectural position

This tmux setup lives in the following conceptual stack:

```

Operating system / keyboard mapping
↓
Terminal emulator (WezTerm, Windows Terminal, etc.)
↓
tmux  ←── this repository
↓
Shell (bash)
↓
Editor (Neovim)

````

Each layer has a single responsibility.

tmux sits **between the terminal emulator and the shell** and is responsible only for:

- window and pane layout
- process orchestration
- input routing
- copy-mode interaction

Everything else is handled elsewhere or explicitly delegated.

---

## Design principles

This configuration follows the same principles as the rest of the `~/dev` environment:

- **Explicit behavior over smart defaults**
- **No plugins**
- **No hidden state**
- **No automatic behavior**
- **Idempotent installation**
- **Clear separation of concerns**

If functionality cannot be expressed simply and locally, it does not belong here.

---

## Responsibilities

### What tmux *does*

- Manages panes and windows
- Handles workflow navigation
- Provides copy-mode with predictable behavior
- Exposes a small number of explicit keybindings

### What tmux explicitly does *not* do

- Edit files (handled by Neovim)
- Persist sessions
- Manage layouts automatically
- Integrate with OS-specific clipboard tools
- Guess user intent
- Act as a plugin host

---

## Pane navigation

Pane focus is navigated using **vim-style keys without a prefix**:

```tmux
bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R
````

This is:
* local to tmux
* explicit
* prefix-free
* independent of editor configuration

Keyboard remapping (e.g. Caps Lock → Control) is handled at the OS level,
not here.

---

## Side panels

Additional panes are created using a small helper script:

```
bin/tmux-sidepanel
```

This script:

* always splits relative to the active pane
* preserves the current working directory
* performs no layout automation
* encodes a procedure, not a policy

tmux does not manage layouts globally.
Pane creation is always an explicit action.

---

## Clipboard handling (OSC 52)

All clipboard interaction is performed using **OSC 52 escape sequences**.

Implementation:

* `osc52-copy.sh` reads stdin
* Encodes content as base64
* Sends an OSC 52 sequence directly to the terminal

tmux does **not** use its native clipboard integration:

```tmux
# set-option -g set-clipboard on   # intentionally disabled
```

Reasons:

* Works consistently over SSH, WSL, and remote systems
* Avoids reliance on X11 / Wayland tooling (`xclip`, `wl-copy`, etc.)
* Matches the clipboard model used in Neovim

The terminal emulator is responsible for placing content into the system clipboard.

---

## File layout

```
tmux/
├── README.md                    # architecture & design notes
├── tmux.conf                    # canonical configuration
├── osc52-copy.sh                # clipboard helper (OSC 52)
├── dev-bootstrap.install.sh     # explicit install hook
└── bin/
    └── tmux-sidepanel           # pane creation helper
```

---

## Loading

This directory is the single source of truth for tmux configuration.

`~/.tmux.conf` should contain **only**:

```tmux
source-file ~/dev/env/terminal/tmux/tmux.conf
```

No other tmux configuration should live outside this repository.

---

## Bootstrap integration

This repository supports installation via `dev-bootstrap` using:

```
dev-bootstrap.install.sh
```

The install script:

* verifies tmux exists
* ensures helper scripts are executable
* optionally links `~/.tmux.conf`
* never overwrites existing configuration implicitly

---

## Non-goals

This setup intentionally does **not** include:

* plugins
* session persistence
* automatic layouts
* complex status bars
* terminal-specific behavior
* editor integration logic
* abstractions for future features

New functionality is added only in response to real, repeated friction.

---

## Stability notes

This configuration is treated as a **stable interface**, not an evolving framework.

Changes are:

* infrequent
* explicit
* intentional

If complexity increases, it should be pushed **down** (to shell/editor)
or **up** (to terminal emulator), not absorbed here.
