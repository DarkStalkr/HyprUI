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
- **11+ Pre-configured Themes**: Catppuccin (Mocha, Macchiato, Frappé, Latte), Tokyo Night (Day, Night, Storm, Moon), Dracula, and a specialized macOS style.
- **Dynamic Accents**: Context-aware colors for different system states (e.g., Purple for Volume, Yellow for Brightness).
- **Hot-swappable**: Cycle through your entire palette with a single keybind (`SUPER+SHIFT+T`).

### 🛠️ Modular Architecture
The shell is divided into verified modules under the `src/` directory to ensure stability and low resource overhead.
- **HyprOSD**: A smart overlay system for Volume and Brightness that respects Wayland layers.
    - **Non-tiling**: Built as an overlay to avoid pushing your windows around.
    - **Segmented Mode**: Includes a classic 16-segment visualizer specifically for the macOS theme.
- **Media Panel**: A stylish MPRIS dashboard.
    - **Contextual**: Automatically fades in when track metadata changes.
    - **Rich UI**: High-resolution album art support and native playback controls.
- **TopBar & SideBar**: Essential panels for workspaces, clock, and pinned applications, optimized for multi-monitor setups.
- **App Launcher**: A smooth, blur-enabled search menu for your applications.

## 🚀 Quick Start

### Prerequisites
- [Quickshell](https://quickshell.org/) (Git version recommended)
- [Hyprland](https://hyprland.org/)
- [Pipewire](https://pipewire.org/) (for audio services)
- [Nerd Fonts](https://www.nerdfonts.com/) (MesloLGS recommended)

### Launching the Shell
Clone the repository and run the entry point:

```bash
quickshell -p ~/Documentos/Projects/HyprUI/src/shell.qml
```

### Keybindings (Hyprland)
Add these to your `hyprland.conf` to interact with the shell:

```conf
# Theme Cycling
bind = SUPER_SHIFT, T, global, hyprui:cycle_theme

# UI Toggles
bind = SUPER, M, global, hyprui:toggle_launcher
bind = SUPER, D, global, hyprui:toggle_dashboard
```

## 🏗️ Technical Foundation
HyprUI is designed for developers who value performance:
- **0% Idle CPU**: Native integration with Quickshell services ensures no unnecessary polling.
- **Sanitized Services**: High-level wrappers for `Audio`, `Mpris`, and `Network` using native C++ backends.
- **Modular Scoping**: Each module is self-contained, making it easy to add or remove features without breaking the core shell.

## 🗺️ Roadmap
- [ ] **Area Picker**: Native screenshot region selection.
- [ ] **Lock Screen**: full `WlSessionLock` integration with PAM support.
- [ ] **Notification Center**: JSON-persistent notification history.
- [ ] **System Stats**: Real-time sparkline graphs for network and CPU usage.

---
<div align=center>
Developed with ❤️ by sohighman
</div>
