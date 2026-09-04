<div align="center">

<img src="./assets/vbc-banner.svg" alt="VBC — VIBE CONTROL" width="900"/>

# Installation Guide

*For what VBC does and how to use it, see [`docx/Documentation.docx`](./docx/Documentation.docx). This file covers installation only.*

</div>

---

## Choose your platform

| Platform | Method | Section |
|---|---|---|
| Windows | Full installer (recommended) | [Windows → Full Installer](#full-installer-recommended) |
| Windows | Binary + script | [Windows → Binary + Script](#binary--script) |
| Linux (Debian/Ubuntu) | `.deb` package | [Linux → `.deb` Package](#deb-package-debianubuntu) |
| Linux (any distro) | Binary + script | [Linux → Binary + Script](#binary--script-1) |
| macOS | Binary + script (recommended) | [macOS → Binary + Script](#binary--script-recommended) |
| macOS | Native `.pkg` (build it yourself) | [macOS → Native .pkg](#native-pkg-build-it-yourself) |
| WSL | Sync from Windows, or install from source | [WSL](#wsl) |

Every method installs the standalone `vbc` binary — **no Node.js required** anywhere below except the optional WSL source install.

---

## Windows

### Full Installer (recommended)

```
windows_installer\VBC_Installer.exe
```

Double-click and follow the prompts. This installs:
- `vbc.exe`, added to your PATH automatically
- The VS Code extension, if VS Code is detected on your machine

No restart needed beyond opening a new terminal window.

### Binary + Script

If you'd rather not run an installer:

```
cd windows
.\vbc-install.bat
```

Open a **new** terminal window afterward, then verify:

```
vbc help
```

To update later, replacing the binary in place:

```
.\vbc-install.bat --update
```

To remove VBC and clean up your PATH:

```
.\vbc-install.bat --uninstall
```

---

## Linux

### `.deb` Package (Debian/Ubuntu)

```bash
sudo apt install ./linux_deb_package/vbc_1.0.1_amd64.deb
# or
sudo dpkg -i linux_deb_package/vbc_1.0.1_amd64.deb
```

Installs the binary to `/usr/local/bin/vbc` — on your PATH immediately, no shell restart required. Auto-installs the VS Code extension if `code` is on PATH.

### Binary + Script

For Fedora, Arch, or any distro without `.deb` support:

```bash
cd linux
bash vbc-install.sh
```

This detects your OS automatically and installs the compiled binary — no Node.js required. Restart your shell, then verify:

```bash
vbc help
```

Update in place:

```bash
bash vbc-install.sh --update
```

Uninstall and clean your shell profile:

```bash
bash vbc-install.sh --uninstall
```

Supported shells: `bash`, `zsh`, `fish`, with a `~/.profile` fallback.

---

## macOS

### Binary + Script (recommended)

```bash
cd macOS
bash vbc-install.sh
```

Same script and behavior as the Linux binary install above — installs the compiled binary, no Node.js required, and offers the same `--update` / `--uninstall` flags.

### Native `.pkg` (build it yourself)

A signed, prebuilt `.pkg` isn't shipped in this repository — Apple's packaging tools (`pkgbuild`) only run on macOS itself, so instead of an unsigned file, you get the build script and build it locally, on your own Mac:

```bash
# 1. Copy the binary and extension into the package folder
cp macOS/vbc-macos-x64-v1.0.1 macOS_package/
cp macOS/vbc-vibe-control-0.1.0.vsix macOS_package/

# 2. Build the .pkg
cd macOS_package
chmod +x build-vbc-macos-pkg.sh
./build-vbc-macos-pkg.sh          # Intel
./build-vbc-macos-pkg.sh arm64    # Apple Silicon
```

This produces a local `.pkg` you install the normal double-click way. Both macOS install paths are fully supported — pick whichever you prefer; the binary + script route is faster, the `.pkg` gives you a native installer experience.

---

## WSL

**From Windows, after installing VBC there (recommended):**

```
vbc sync wsl
```

If more than one WSL distro is registered, you'll be asked which one(s) to link. This is the fastest path if you're already running VBC on Windows.

**From inside WSL directly**, if you'd rather set it up independently (requires Node.js already installed in that distro): see the *source install* note at the end of this guide.

---

## VS Code Extension

Every install method above installs the extension automatically when VS Code is detected. To install it manually at any time:

```bash
code --install-extension vbc-vibe-control-0.1.0.vsix
```

The `.vsix` file is included in each platform folder (`linux/`, `macOS/`, `windows/`) — use whichever copy is convenient.

Then reload VS Code: `Ctrl+Shift+P` → **Developer: Reload Window**.

---

## Updating

| Install type | Command |
|---|---|
| Windows / Linux / macOS binary + script | Re-run the install script with `--update` |
| Windows installer | Re-run `VBC_Installer.exe` |
| Linux `.deb` | `sudo apt install ./linux_deb_package/vbc_<new-version>_amd64.deb` |
| WSL (synced from Windows) | Re-run `vbc sync wsl` after updating Windows |

---

## Uninstalling

| Install type | Command |
|---|---|
| Binary + script (any platform) | Re-run the install script with `--uninstall` |
| Windows installer | Uninstall from *Settings → Apps*, same as any Windows program |
| Linux `.deb` | `sudo apt remove vbc` |

---

## Troubleshooting

**`vbc: command not found` after install** — open a brand-new terminal window; PATH changes don't apply to already-open shells.

**VS Code extension didn't install automatically** — install it manually (see [VS Code Extension](#vs-code-extension) above); this usually just means VS Code wasn't on PATH at install time.

**Wrong binary for your Mac's chip** — the binary in `macOS/` is Intel (x64), which also runs on Apple Silicon via Rosetta 2. For a native Apple Silicon build, use the `arm64` option when building the `.pkg` (see [Native .pkg](#native-pkg-build-it-yourself)).

For everything else — commands, usage, and how VBC works — see [`docx/Documentation.docx`](./docx/Documentation.docx).
