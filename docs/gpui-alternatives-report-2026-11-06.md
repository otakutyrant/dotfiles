I split your declared applications into four groups and searched with three
subagents. **The strongest candidates are Disktree, Skwir, Moeka, Termy, Look,
clp, Orion, and Omasend.** Many other matches are experimental or cover only
part of your current workflow.

This is a broad survey as of **November 6, 2026**, rather than a guarantee that
every GPUI project has been discovered. “Linux supported” below means upstream
documents support; we haven’t tested these applications on your machine. GPUI
forks such as GPUI-CE, gpui-fast, and gpui-omarchy are included and identified
where verified.

**Files, editors, and office applications**

| Your package                   | GPUI alternatives                                           | Fit and limitations                                                                                                                                                  |
| ------------------------------ | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Baobab**                     | [Disktree](https://github.com/tobi/disktree)                | Direct replacement: disk-usage treemap, navigation, and reviewed deletion. Uses gpui-omarchy.                                                                        |
| **Nautilus / Yazi**            | [Skwir](https://github.com/skwir-org/skwir)                 | Linux-first file manager with tabs, dual panes, search, remote mounts, tags, and previews. Upstream provides a flake and Home Manager module.                        |
|                                | [Flea](https://github.com/thisisgm/flea)                    | Linux/Omarchy-first; multiple views, network shares, previews, archives, and bulk renaming. Recent GPUI rewrite; installation currently targets Omarchy.             |
|                                | [Pifile](https://github.com/raythurman2386/pifile)          | Smaller, keyboard-first Linux file manager covering ordinary file operations.                                                                                        |
|                                | [zex](https://github.com/ejalxndr/zex)                      | File explorer and disk-usage companion sharing Zed configuration/themes. Early; advertises Linux binaries.                                                           |
| **File Roller / ouch**         | [Flea](https://github.com/thisisgm/flea)                    | Compression/extraction inside a file manager. No dedicated standalone GPUI archive manager verified.                                                                 |
| **GNOME Text Editor / Neovim** | [Zed](https://github.com/zed-industries/zed)                | Most established GPUI editor; Linux support and Vim mode. Switching would require replacing your Neovim configuration and plugin workflows.                          |
|                                | [Fulgur](https://github.com/fulgur-app/Fulgur)              | Smaller text/code editor with Markdown preview, multi-cursor editing, CSV editing, log following, and SSH. Linux releases available.                                 |
|                                | [helix-gpui](https://github.com/polachok/helix-gpui)        | Experimental Helix frontend; a modal-editing lead rather than an established Neovim replacement.                                                                     |
| **Typora**                     | [Moeka](https://moeka.app/)                                 | Closest direct candidate: local Markdown editing, formulas/diagrams, file tree, and Git/diffs. Linux x86_64/ARM64 downloads; source availability wasn’t established. |
|                                | [Vellum](https://github.com/wzzc-dev/vellum)                | Explicitly Typora-style GPUI WYSIWYG editing. Early; Linux support/release coverage not established.                                                                 |
|                                | [Zorite](https://github.com/packetThrower/zorite)           | Linux-supported Markdown journal with wiki links and PDF tools. Notes use SQLite, so its storage workflow differs from Typora. Upstream flake available.             |
|                                | [Scoria](https://github.com/ragtux/Scoria)                  | GPUI knowledge base opening Obsidian vaults. Very early: reader implemented, writer in progress.                                                                     |
| **Papers**                     | [pdf-reader-gpui](https://github.com/Lej77/pdf-reader-gpui) | Genuine but explicitly experimental PDF reader; Linux release coverage unclear.                                                                                      |
|                                | [Zorite](https://github.com/packetThrower/zorite)           | Integrated PDF viewing, annotations, and forms; part of a larger journal application.                                                                                |
| **WPS Office**                 | [ibisOffice](https://github.com/ibisjp/ibis-office)         | GPUI-fork office suite advertising DOCX/XLSX/PPTX editing and Linux AppImages. Early v0.x; document compatibility needs careful evaluation.                          |
| **vimv**                       | [Flea](https://github.com/thisisgm/flea)                    | Bulk-renaming overlap, without the same editor-driven interface.                                                                                                     |
| **Calibre / page**             | No close replacement verified                               | File previews don’t replace Calibre’s library/conversion/device functions; an editor doesn’t replace `page`’s pager integration.                                     |

**Desktop, terminal, and system tools**

| Your package                    | GPUI alternatives                                                                                                                              | Fit and limitations                                                                                                                                                                                                                    |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Kitty**                       | [Termy](https://github.com/lassejlv/termy)                                                                                                     | Conventional terminal with Alacritty core, tabs, splits, search, layouts, and Linux releases.                                                                                                                                          |
|                                 | [tty7](https://github.com/l0ng-ai/tty7)                                                                                                        | Daemon-backed persistent terminals, tabs/splits, SSH, and agent features. Linux builds available.                                                                                                                                      |
|                                 | [zebrilus / zz](https://github.com/autistic-computer/zebrilus)                                                                                 | Experimental GPUI/Ghostty terminal multiplexer.                                                                                                                                                                                        |
| **Kitty / SSH workflows**       | [NyaTerm](https://github.com/nyakang/nyaterm), [Shellwing](https://github.com/hivepaas/shellwing), [Navop](https://github.com/feigeCode/navop) | Linux-supported terminal/remote-work clients. NyaTerm includes SSH/SFTP and other remote protocols; Shellwing emphasizes SSH; Navop also includes database and remote-desktop tools. They retain the need for a shell such as Nushell. |
| **Walker**                      | [Look](https://github.com/kunkka19xx/look)                                                                                                     | Strong candidate: application/file search, clipboard, commands, explicit Sway integration, and upstream Nix/Home Manager support. Linux UI uses GPUI; macOS uses SwiftUI.                                                              |
|                                 | [Loungy](https://github.com/MatthiasGrandl/Loungy)                                                                                             | GPUI launcher, but inactive with rough Linux support and missing Linux clipboard integration.                                                                                                                                          |
| **Clipcat**                     | [clp](https://github.com/lostf1sh/clp)                                                                                                         | Wayland clipboard daemon plus GPUI popup; text/images, history, pins, and search. Explicit Sway instructions. Young project.                                                                                                           |
| **GNOME System Monitor / btop** | [Rustat](https://github.com/salman0ansari/rustat)                                                                                              | Linux resource/process monitor with CPU, RAM, network, disks, GPU, and sensors. Releases available.                                                                                                                                    |
|                                 | [Resource Monitor](https://github.com/TheOutcastVirus/resource-monitor), [System Pulse](https://github.com/eas4ai/system-pulse)                | Additional Linux GPUI monitor projects; earlier-stage candidates.                                                                                                                                                                      |
| **pwvucontrol / wiremix**       | [Orion](https://github.com/gardun0/orion)                                                                                                      | PipeWire mixer, routing, per-application controls, and virtual devices. Linux Wayland/X11; pre-1.0.                                                                                                                                    |
| **wayshot / waysip**            | [Dockeep](https://github.com/hazyio/dockeep)                                                                                                   | Screenshot capture and organization, but Linux/Sway support wasn’t established. Tentative only.                                                                                                                                        |

Two larger shell projects overlap several of your desktop packages:

| Project                                                   | Potential replacements                                                                            | Important limitation                                                                                                                                                 |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Mandara](https://github.com/theHamdiz/mandara)           | Ironbar, Walker, nwg-notifications, Clipcat, Waytrogen/awww, screenshot tools, and lock-screen UI | GPUI/wgpu shell explicitly documenting **Sway** and NixOS support. Broad upstream feature claims; suitability needs testing. It doesn’t replace the Sway compositor. |
| [GPUi Shell](https://github.com/andre-brandao/gpui-shell) | Bar, launcher, notifications, wallpaper controls, audio, NetworkManager, and Bluetooth controls   | Early project documenting **Hyprland/Mango/Niri**, without established Sway support. Includes an upstream flake.                                                     |

No verified standalone GPUI equivalent emerged for **Sway, swayidle, wkeys, or
fcitx5-configtool**. NetworkManager and Blueman functionality appears mainly in
the bundled shells.

**Media, productivity, and transfers**

| Your package                        | GPUI alternatives                                                                                                                                    | Fit and limitations                                                                                                                                                                                                           |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **LocalSend**                       | [Omasend](https://github.com/huacnlee/omasend)                                                                                                       | Direct protocol-compatible candidate that communicates with LocalSend apps. Linux x86_64/ARM64; uses gpui-omarchy and GPUI Kit.                                                                                               |
| **qBittorrent / rqbit**             | [FluxDown](https://github.com/zerx-lab/FluxDown)                                                                                                     | Linux download manager supporting BitTorrent and HTTP/FTP/HLS/DASH. Uses gpui-fast. Torrent feature parity hasn’t been established.                                                                                           |
| **yt-dlp**                          | [FluxDown](https://github.com/zerx-lab/FluxDown/releases)                                                                                            | YouTube resolver plugin provides partial overlap; equivalent site coverage and CLI compatibility aren’t established.                                                                                                          |
| **OBS Studio**                      | [Cap](https://github.com/CapSoftware/Cap)                                                                                                            | GPUI migration has shipped, including Linux builds. Recording, editing, and sharing overlap; no verified replacement for OBS’s streaming/scene capabilities. [Migration details](https://cap.so/blog/rebuilding-cap-in-gpui). |
| **PhotoCraft**                      | [Impressy](https://github.com/willmove/impressy)                                                                                                     | Linux image toolbox: crop, resize, collage, conversion, compression, and watermarks. No established layer/PSD parity.                                                                                                         |
| **PhotoCraft / Imageflow**          | [Panoply](https://github.com/anzal1/panoply)                                                                                                         | Linux-supported beta toolbox for image conversion/compression, resizing, OCR, and related operations. Partial workflow replacement.                                                                                           |
| **OxiMedia / conversion workflows** | [Frame](https://www.framegui.app/), [Panoply](https://github.com/anzal1/panoply)                                                                     | Linux media-conversion GUIs. Frame uses GPUI-CE and FFmpeg/FFprobe; neither replaces a media-library API.                                                                                                                     |
| **whisper.cpp workflows**           | [Dictate](https://github.com/joshuadavidthomas/dictate)                                                                                              | Linux/Wayland dictation plus WAV transcription CLI; uses a transcribe.cpp backend.                                                                                                                                            |
|                                     | [Scribe](https://scribe.rs/), [Sayso](https://github.com/watzon/sayso), [LokalBot](https://github.com/stevyhacker/LokalBot/tree/master/LinuxWindows) | GPUI speech/dictation applications with Linux support. Scribe and LokalBot are alpha; Sayso uses sherpa-onnx on Linux. Backend and workflow differences matter for your subtitle-generation use.                              |
| **TickTick**                        | [gpui-todos](https://github.com/duanebester/gpui-todos), [BMO](https://github.com/rubbieKelvin/bmo)                                                  | Basic todo demonstration and WIP Pomodoro timer respectively; neither is a full replacement.                                                                                                                                  |
|                                     | [Aviary](https://github.com/Catvert/aviary), [Remindr](https://github.com/LeadcodeDev/remindr)                                                       | Partial overlap: Aviary provides Linux email/calendar/mail-tag kanban; Remindr is an early Notion-style project without established Linux coverage.                                                                           |

No usable Linux GPUI replacement was verified for **mpv, Chrome, Anki, WeChat,
QQ, or Nutstore**. Browser experiments, a WeChat UI clone, and Anki-export tools
surfaced, but don’t provide those applications’ core functions.

**Development and agent interfaces**

These largely provide a graphical interface around tools you already use.

| Your package/workflow                     | GPUI alternatives                                                                                                                                                                                                             | Fit                                                                                                                                                                                  |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Git / some gh workflows**               | [GitComet](https://github.com/Auto-Explore/GitComet), [rgitui](https://github.com/noahbclarkson/rgitui)                                                                                                                       | Linux Git GUIs for staging, diffs, branches, and related operations. GitComet uses GPUI-CE; rgitui explicitly warns it is early development. Both retain underlying Git tooling.     |
| **Agent CLI interfaces**                  | [Waku](https://github.com/egoist/waku)                                                                                                                                                                                        | Linux GPUI interface explicitly supporting your **Codex, Kimi Code, and OpenCode** CLIs. Keeps those agents installed underneath.                                                    |
|                                           | [Farcaster](https://github.com/behzade/farcaster)                                                                                                                                                                             | Linux interface supporting existing harnesses, embedded terminal, and especially deep Neovim integration. A particularly relevant fit for your preferences.                          |
|                                           | [Arbor](https://github.com/penso/arbor)                                                                                                                                                                                       | Linux-supported agent/worktree workspace with terminals, managed processes, diffs, and PR context.                                                                                   |
|                                           | [Vibex](https://github.com/vibex-ai/vibex)                                                                                                                                                                                    | Early Linux-supported GPUI/ACP workbench with agents, Git, terminals, and remote clients.                                                                                            |
| **Additional agent-workspace candidates** | [Sailry](https://github.com/sailry/sailry-harness), [WSP](https://github.com/wsp-labs/wsp), [Zeron](https://github.com/zeronsh/comet), [Krill](https://github.com/craftowen/krill), [Hadron](https://github.com/s0lda/hadron) | Further projects listed in the [GPUI catalogue](https://github.com/zed-industries/awesome-gpui). Less deeply checked here; platform support and maturity need individual evaluation. |

Compilers, language servers, formatters, Nix tooling, PostgreSQL itself, and
command-line infrastructure generally have no meaningful GPUI replacement.
Database GUIs, for example, would supplement your PostgreSQL package.

For **your pinned nixpkgs unstable input**, I verified these exact package
identities:

| Attribute                  | Version  |
| -------------------------- | -------- |
| `pkgs.unstable.disktree`   | `0.10.1` |
| `pkgs.unstable.zed-editor` | `1.24.2` |
| `pkgs.unstable.gitcomet`   | `0.2.3`  |

Watch for name collisions: nixpkgs’ **`clp`, `frame`, `panoply`, and `vellum`
are unrelated applications**, while `orion` is a removed alias. The presence of
those attribute names doesn’t establish packaging for the projects above.

I’d investigate **Disktree → Skwir → Moeka → clp → Orion → Omasend**, followed
by **Farcaster** for your Neovim-centered agent workflow. No configuration files
were changed.

English feedback: “Split the packages into **groups**” is more natural than
“into bulks.”  
Corrected prompt: “List all GPUI alternatives to my packages. Split the packages
into groups and use subagents to speed up the search.”

Skills applied: english-writing-teacher
