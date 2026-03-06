<h1 align=center>HyprUI</h1>

<div align=center>

![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue?style=for-the-badge&logo=hyprland&logoColor=white)
![Quickshell](https://img.shields.io/badge/Framework-Quickshell-orange?style=for-the-badge)
![Qt6](https://img.shields.io/badge/Toolkit-Qt6-green?style=for-the-badge&logo=qt)

</div>

**HyprUI** is a high-performance, modular desktop shell ecosystem for Hyprland. Built on the **Quickshell/Qt6** framework, it bridges the gap between minimalist C utilities and modern UX by providing reactive widgets, glassmorphism aesthetics, and a powerful dynamic theme engine.

## ✨ Core Features

### 🎨 Reactive Theme Engine
HyprUI features a high-priority theme singleton (`HyprUITheme.qml`) that allows for instant, real-time styling changes without restarting the shell.
- **11+ Pre-configured Themes**: Catppuccin (Mocha, Macchiato, Frappé, Latte), Tokyo Night (Day, Night, Storm, Moon), Dracula, and macOS.
- **Dynamic Accents**: Context-aware colors for different system states (e.g., Green for Battery, Yellow for Brightness).
- **Unified Typography**: System-wide integration of **MesloLGS NF** for a consistent nerd-font aesthetic.
- **Hot-swappable**: Cycle through your entire palette with a single keybind (`SUPER+SHIFT+T`).

### 🛠️ Modular Architecture
The shell is divided into verified modules organized at the root for maximum performance and stability.
- **Unified Control Center**: A modern, scrollable vertical panel (`SUPER+C`) integrating:
    - **System Toggles**: Fast Wi-Fi and Bluetooth management.
    - **Physical Meters**: Thicker (32px), solid Volume and Brightness sliders with mobile-inspired physics.
    - **Integrated Media**: Full MPRIS support with cover art, synchronized playback controls, and metadata.
    - **Notification History**: A dedicated section for tracking system alerts.
- **HyprOSD**: A bold global overlay for Volume and Brightness.
    - **Non-tiling**: Built as an overlay to avoid pushing windows.
    - **High Visibility**: Large 36px icons and thick 32px progress bars.
- **TopBar & SideBar**: Essential panels for workspaces, clock, and pinned applications, optimized for multi-monitor setups.
- **App Launcher**: A smooth, blur-enabled search menu (`SUPER+M`).

## 🚀 Quick Start

### Prerequisites
- [Quickshell](https://quickshell.org/) (Git version recommended)
- [Hyprland](https://hyprland.org/)
- [Pipewire](https://pipewire.org/) (for audio services)
- [MesloLGS NF](https://github.com/romkatv/powerlevel10k-media) (Required font)

### Launching the Shell
Clone the repository and run the entry point from the root:

```bash
quickshell -p ~/Documentos/Projects/HyprUI/shell.qml
```

### Keybindings (Hyprland)
Add these to your `hyprland.conf`:

```conf
# Theme Cycling
bind = SUPER_SHIFT, T, global, hyprui:cycle_theme

# UI Toggles
bind = SUPER, M, global, hyprui:toggle_launcher
bind = SUPER, D, global, hyprui:toggle_dashboard
bind = SUPER, C, global, hyprui:toggle_control_center
```

## 🏗️ Technical Foundation
- **0% Idle CPU**: Native integration with Quickshell services ensures no unnecessary polling.
- **Sanitized Services**: High-level wrappers for `Audio`, `Mpris`, `UPower`, and `Network`.
- **Legacy Isolation**: Forked artifacts from `caelestial-shell` are isolated in `caelestial_legacy/` to maintain a clean workspace.

## 🗺️ Roadmap
- [ ] **Area Picker**: Native screenshot region selection.
- [ ] **Lock Screen**: full `WlSessionLock` integration with PAM support.
- [ ] **System Stats**: Real-time sparkline graphs for network and CPU usage.

---
<div align=center>
Developed with ❤️ by sohighman
</div>
