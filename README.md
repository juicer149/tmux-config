# tmux environment

This repository contains the canonical tmux configuration used in my
development environment.

It is deliberately small, explicit, and procedural.

tmux is treated here as an **execution and workflow orchestrator** —
not a shell framework, not an editor extension, and not a stateful system.

---

## Architectural position

This tmux setup lives in the following conceptual stack:

```text
Operating system / keyboard mapping
↓
Terminal emulator (WezTerm, Windows Terminal, etc.)
↓
tmux  ←── this repository
↓
Shell (bash)
↓
Editor (Neovim)
```

Each layer has a single responsibility.

tmux sits **between the terminal emulator and the shell** and is responsible only for:

* window and pane layout
* process orchestration
* input routing
* copy-mode interaction
* terminal capability negotiation

Everything else is handled elsewhere or explicitly delegated.

---

## Design principles

This configuration follows the same principles as the rest of the `~/dev` environment:

* **Explicit behavior over smart defaults**
* **No plugins**
* **No hidden state**
* **No automatic behavior**
* **Idempotent installation**
* **Clear separation of concerns**
* **Terminal-native behavior before abstractions**

If functionality cannot be expressed simply and locally, it does not belong here.

---

## Responsibilities

### What tmux does

* Manages panes and windows
* Handles workflow navigation
* Provides copy-mode with predictable behavior
* Preserves terminal color fidelity between terminal emulator and editor
* Exposes a small number of explicit keybindings

### What tmux explicitly does not do

* Edit files
* Persist sessions automatically
* Manage layouts automatically
* Integrate with OS-specific clipboard tools
* Guess user intent
* Act as a plugin host
* Override editor navigation
* Own prefix-free Vim navigation keys

Neovim, fzf, shells, and terminal programs should be allowed to own their normal
interactive keybindings.

---

## Terminal color handling

tmux sits between the terminal emulator and applications such as Neovim.

This means tmux must correctly advertise and pass through terminal capabilities,
especially 24-bit RGB color.

Without explicit truecolor negotiation, custom themes can render incorrectly.
For example, a carefully chosen color such as:

```text
#F5E6D6
```

may be degraded into a rough xterm-256 approximation such as:

```text
#FFD7D7
#FFD7AF
```

This caused visible color drift when building a custom theme across:

```text
WezTerm → tmux → Neovim
```

The configuration therefore explicitly sets:

```tmux
set -g default-terminal "tmux-256color"

set -as terminal-features ",xterm-256color:RGB"
set -as terminal-features ",wezterm:RGB"
set -as terminal-features ",tmux-256color:RGB"

set -as terminal-overrides ",xterm-256color:Tc"
set -as terminal-overrides ",wezterm:Tc"
set -as terminal-overrides ",tmux-256color:Tc"
```

The goal is not visual decoration.

The goal is **color correctness**.

tmux should preserve the color language defined by the terminal and editor,
not reinterpret it.

---

## Italic text

Italic support is enabled explicitly:

```tmux
set -ga terminal-overrides ',*:sitm=\E[3m'
set -ga terminal-overrides ',*:ritm=\E[23m'
```

This ensures that terminal applications can use italic text consistently when
the terminal emulator supports it.

---

## Visual focus

Pane borders are used as a lightweight focus indicator.

Inactive panes use a low-contrast dark yellow / olive tone:

```tmux
set -g pane-border-style fg=colour58
```

The active pane uses bright yellow:

```tmux
set -g pane-active-border-style fg=yellow
```

The status line uses the same stable accent:

```tmux
set -g status-style fg=yellow,bg=default
```

This keeps tmux visually quiet while still making focus obvious.

---

## Input and interaction model

The configuration uses vi-style copy-mode keys:

```tmux
set -g mode-keys vi
```

Mouse support is enabled:

```tmux
set -g mouse on
```

Mouse support is not treated as the primary interface.
It exists as a practical fallback for resizing, selecting, and inspecting panes.

Escape timing is reduced:

```tmux
set-option -sg escape-time 10
```

Focus events are enabled:

```tmux
set-option -g focus-events on
```

This helps terminal applications react correctly when focus changes.

---

## Window navigation

Window navigation keeps the standard tmux model:

```text
prefix + n   next window
prefix + p   previous window
prefix + &   kill window
```

Windows are treated as larger workspaces.

Examples:

```text
window 1: project
window 2: server
window 3: logs
window 4: scratch
```

The configuration removes `prefix + L` as a window-switch binding if present:

```tmux
unbind-key L
```

This keeps the conceptual model clean:

```text
n / p      window navigation
h/j/k/l    pane navigation
```

---

## Pane creation

Pane creation keeps the standard tmux bindings:

```text
prefix + %   split left/right
prefix + "   split top/bottom
prefix + z   zoom current pane
```

No custom split bindings are required.

The default tmux grammar is terse, stable, and worth learning.

Common workflow:

```text
prefix + %   create a right-side pane
prefix + "   create a lower pane
prefix + z   temporarily zoom the current pane
```

`prefix + z` is especially useful when a pane becomes the temporary focus of
work, such as editing a file, reading logs, or inspecting command output.

---

## Pane navigation

Pane focus is navigated using Vim-style keys with the tmux prefix:

```tmux
bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R
```

This gives:

```text
prefix + h   move to pane on the left
prefix + j   move to pane below
prefix + k   move to pane above
prefix + l   move to pane on the right
```

Pane movement is geometric.

It moves relative to the current pane, not according to creation order.

Example layout:

```text
┌───────────────┬───────────────┐
│ A             │ B             │
├───────────────┼───────────────┤
│ C             │ D             │
└───────────────┴───────────────┘
```

If focus is in `B`:

```text
prefix + j
```

moves to `D`.

If focus is in `A`:

```text
prefix + j
```

moves to `C`.

This matches the mental model of spatial movement.

---

## Why pane navigation uses prefix

This setup intentionally avoids prefix-free bindings such as:

```tmux
bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R
```

Those keys are useful inside terminal applications.

Neovim, fzf, shells, REPLs, and other tools should be allowed to interpret their
own keybindings without tmux intercepting them first.

The chosen model is therefore:

```text
Ctrl-b h/j/k/l   tmux pane movement
Ctrl-h/j/k/l     application-level behavior
```

This keeps tmux powerful without making it invasive.

---

## Sessions

tmux sessions are top-level work contexts.

A session can be created with a specific working directory using `-c`:

```bash
tmux new-session -s swedesweets -c ~/dev/project/work/swedesweets_mvp
```

This is appropriate when starting tmux from outside tmux.

When already inside tmux, create the session detached and then switch to it:

```bash
tmux new-session -d -s swedesweets -c ~/dev/project/work/swedesweets_mvp
tmux switch-client -t swedesweets
```

As a one-liner:

```bash
tmux new-session -d -s swedesweets -c ~/dev/project/work/swedesweets_mvp \; switch-client -t swedesweets
```

The `-d` flag is important inside an existing tmux session.

Without it, tmux tries to nest one session inside another and warns:

```text
sessions should be nested with care, unset $TMUX to force
```

Nested tmux sessions are usually not desired.

A better model is:

```text
create detached session
↓
switch current client to that session
```

---

## Working directory behavior

A session can be opened directly in a project directory:

```bash
tmux new-session -d -s env-tmux -c ~/dev/env/terminal/tmux \; switch-client -t env-tmux
```

A new session can also be created from the current pane path:

```bash
tmux new-session -d -s newname -c "#{pane_current_path}" \; switch-client -t newname
```

This is useful when promoting the current working directory into its own
session.

---

## Clipboard handling

Clipboard interaction is performed using OSC 52 escape sequences.

Implementation:

```text
osc52-copy.sh
```

The helper script:

* reads stdin
* base64-encodes the content
* sends an OSC 52 sequence directly to the terminal

The copy-mode binding is:

```tmux
bind-key -T copy-mode-vi y \
  send -X copy-pipe-and-cancel "$HOME/dev/env/terminal/tmux/osc52-copy.sh"
```

tmux native clipboard integration is intentionally disabled:

```tmux
# set-option -g set-clipboard on   # intentionally disabled
```

Reasons:

* Works consistently over SSH, WSL, and remote systems
* Avoids reliance on X11 / Wayland tooling such as `xclip` or `wl-copy`
* Matches the clipboard model used in Neovim
* Keeps clipboard behavior explicit and terminal-driven

The terminal emulator is responsible for placing OSC 52 content into the system
clipboard.

---

## File layout

```text
tmux/
├── README.md                    # architecture & design notes
├── tmux.conf                    # canonical configuration
├── osc52-copy.sh                # clipboard helper using OSC 52
├── dev-bootstrap.install.sh     # explicit install hook
└── bin/
    └── tmux-sidepanel           # optional pane creation helper
```

---

## Loading

This directory is the single source of truth for tmux configuration.

`~/.tmux.conf` should contain only:

```tmux
source-file ~/dev/env/terminal/tmux/tmux.conf
```

No other tmux configuration should live outside this repository.

After editing the canonical config, reload it with:

```bash
tmux source-file ~/dev/env/terminal/tmux/tmux.conf
```

---

## Bootstrap integration

This repository supports installation via:

```text
dev-bootstrap.install.sh
```

The install script:

* verifies tmux exists
* ensures helper scripts are executable
* verifies the repo-local `tmux.conf` exists
* optionally links `~/.tmux.conf`
* never overwrites existing configuration implicitly

The script is intended to be:

* explicit
* idempotent
* safe to re-run

---

## Current key model

```text
prefix + n       next window
prefix + p       previous window
prefix + &       kill window

prefix + %       split left/right
prefix + "       split top/bottom
prefix + z       zoom current pane

prefix + h       pane left
prefix + j       pane down
prefix + k       pane up
prefix + l       pane right
```

The core grammar is:

```text
windows = n / p
panes   = h / j / k / l
layout  = % / " / z
```

This keeps tmux close to its defaults while adding only the navigation that
reduces real friction.

---

## Non-goals

This setup intentionally does not include:

* plugins
* session persistence
* automatic layouts
* complex status bars
* terminal-specific behavior beyond capability negotiation
* editor integration logic
* global key interception
* abstractions for hypothetical future workflows

New functionality is added only in response to real, repeated friction.

---

## Stability notes

This configuration is treated as a stable interface, not an evolving framework.

Changes should be:

* infrequent
* explicit
* intentional
* documented

If complexity increases, it should be pushed down to the shell/editor or up to
the terminal emulator, not absorbed into tmux.

tmux should remain a thin, reliable orchestration layer.
