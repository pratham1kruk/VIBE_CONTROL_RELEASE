<div align="center">

<img src="./assets/vbc-banner.svg" alt="VBC — VIBE CONTROL" width="900"/>

### Version control for vibe coders

**Auto-tracks your edit history as you code. No staging. No commit messages required. Just flow.**

![Version](https://img.shields.io/badge/Version-1.0.1-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20WSL-blue?style=flat-square)
![VS Code](https://img.shields.io/badge/VS%20Code-Extension%20Included-007ACC?style=flat-square&logo=visualstudiocode)
![License](https://img.shields.io/badge/License-Proprietary-lightgrey?style=flat-square)

**[Install](./documentation.md) · [Full Documentation](./docx/Documentation.docx) · [Quick Start](#quick-start)**

</div>

---

## What is VBC

Traditional version control asks you to decide, in advance, which moment is worth remembering. When you're actively working something out — trying an approach, backing out of it, trying another — that decision gets in the way. You either commit too often and drown the history in noise, or you commit too rarely and lose the steps in between.

**VBC removes the decision.** Start the watcher, and every save becomes part of your project's history automatically — no staging, no commit message required, no interruption to your flow. When you reach a point actually worth marking, you commit *that* — a file, a session, a full checkpoint — in one short command, with a message if you want one.

It's not a replacement for Git. It's what happens *before* Git: the fine-grained record of how you got somewhere, so that by the time you're ready to push, the story is already written.

---

## Why it exists

- **Coding-in-the-moment doesn't map to staged commits.** The unit of work while you're actively building something is a save, not a deliberate checkpoint — VBC tracks at that resolution.
- **Byte-exact, every time.** Text, images, PDFs, binaries — everything round-trips exactly. Nothing is summarized, diffed lossily, or reconstructed.
- **Checkpoints are yours to name.** When you do want a stable snapshot, you choose the number — VBC never silently renumbers or auto-increments behind your back.
- **Fully offline.** No account, no sync, no telemetry. Everything lives in a `.vbc/` folder at your project root.

---

## Key features

| | |
|---|---|
| **Automatic tracking** | A background watcher flags every save the moment it happens — full rewrite, partial edit, copy, or revert, each recorded distinctly |
| **Manual commits, your way** | Commit a single file or your whole working set, with or without a message |
| **Numbered checkpoints** | Drop a full project snapshot at any point, under a checkpoint number you choose |
| **Visual flag language** | Every change is a typed, colored flag — glance at your history and know instantly what kind of change it was |
| **VS Code integration** | A full extension: inline flag indicators, a visual history graph, and every command from the Command Palette |
| **Cross-platform** | Native standalone binaries for Windows, Linux, and macOS, plus first-class WSL support |
| **No dependencies to run** | Every install method ships a compiled binary — Node.js is never required just to use VBC |

---

## Quick Start

```bash
cd my-project
vbc init                                            # sets up .vbc/ + .vbcignore
vbc watch                                           # start the watcher — code normally from here

# save files as you work; flags appear automatically

vbc plot we flag src/main.py -ms "login done"       # commit one file
vbc plot us flag -ms "session 1 complete"           # commit everything flagged
vbc plot ckp as ckp1 -ms "v1.0 — auth + dashboard"  # full checkpoint, your number
```

Run `vbc help` at any time for the full command list, or open the Command Palette in VS Code and search **VBC**.

For the complete picture — every command, the flag system, `.vbcignore`, the VS Code extension, and how VBC stores your data — see the full **[Documentation](./docx/Documentation.docx)**.

---

## Install

Install instructions for every platform — Windows, Linux, macOS, and WSL — live in **[`documentation.md`](./documentation.md)**. Every method installs a standalone binary; none require Node.js.

| Platform | Fastest path |
|---|---|
| Windows | `windows_installer\VBC_Installer.exe` |
| Linux (Debian/Ubuntu) | `sudo apt install ./linux_deb_package/vbc_1.0.1_amd64.deb` |
| macOS | `cd macOS && bash vbc-install.sh` |
| WSL | `vbc sync wsl`, from Windows, after installing there |

---

## What's in this repository

```
VIBE_CONTROL_RELEASE/
├── docx/                    ← full documentation (what, why, how)
├── windows_installer/       ← full Windows installer
├── windows/                 ← standalone binary + script
├── linux_deb_package/       ← .deb package (Debian/Ubuntu)
├── linux/                   ← standalone binary + script
├── macOS/                   ← standalone binary + script
├── macOS_package/           ← build your own native .pkg
├── documentation.md         ← installation guide (this repo's other doc)
└── README.md                ← you are here
```

This repository ships compiled, ready-to-run releases only — no source code.

---

## License

© 2025 Pratham Kumar Uikey — All rights reserved. See [LICENSE](./LICENSE).

<div align="center">

Made by **Pratham Kumar Uikey** · [github.com/pratham1kruk](https://github.com/pratham1kruk)

*Built for vibe coders.*

</div>
