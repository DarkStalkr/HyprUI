<h1 align=center>HyprUI</h1>

<div align=center>

![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue?style=for-the-badge&logo=hyprland&logoColor=white)
![Quickshell](https://img.shields.io/badge/Framework-Quickshell-orange?style=for-the-badge)
![Qt6](https://img.shields.io/badge/Toolkit-Qt6-green?style=for-the-badge&logo=qt)

</div>

**HyprUI** is a high-performance, modular desktop shell ecosystem for Hyprland. Built on the **Quickshell/Qt6** framework, it bridges the gap between minimalist C utilities and modern UX by providing reactive widgets, glassmorphism aesthetics, and a powerful dynamic theme engine.

https://github.com/user-attachments/assets/d3de58dd-9271-41c7-9f6b-4acef0785a4b

## Core Features

### Reactive Theme Engine
HyprUI features a high-priority theme singleton (`HyprUITheme.qml`) that allows for instant, real-time styling changes without restarting the shell.
- **11+ Pre-configured Themes**: Catppuccin (Mocha, Macchiato, Frappé, Latte), Tokyo Night (Day, Night, Storm, Moon), Dracula, and macOS.
- **Dynamic Accents**: Context-aware colors for different system states (e.g., Green for Battery, Yellow for Brightness).
- **Unified Typography**: System-wide integration of **MesloLGS NF** for a consistent nerd-font aesthetic.
- **Hot-swappable**: Cycle through your entire palette with a single keybind (`SUPER+SHIFT+T`).

### Modular Architecture
The shell is divided into verified modules organized at the root for maximum performance and stability.
- **Sidebar-based Control Center**: A modern multi-pane layout (`SUPER+C`) integrating:
    - **System Pane**: Fixed power/session controls with scrollable connectivity and audio settings.
    - **Media Pane**: Full MPRIS support with cover art and metadata (volume bars removed for a cleaner look).
    - **Notifications Pane**: Dedicated history for tracking system alerts.
- **Sequential Notifications**: A smart alert system that displays notifications one-by-one with smooth 3-second expiration and queuing.
- **HyprOSD**: A bold global overlay for Volume and Brightness that avoids window displacement.
- **TopBar & SideBar**: Essential panels for workspaces and system status, optimized for multi-monitor setups.

## Quick Start

### Prerequisites
- [Quickshell](https://quickshell.org/) (Git version recommended)
- [Hyprland](https://hyprland.org/)
- [Pipewire](https://pipewire.org/) (for audio services)
- [MesloLGS NF](https://github.com/romkatv/powerlevel10k-media) (Required font)
- [wlogout](https://github.com/ArtsyMacaw/wlogout) (Triggers wayland based logout menu)

### Launching the Shell
Clone the repository and run the entry point from the root:

```bash
quickshell -p ~/HyprUI/shell.qml
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

## Technical Foundation
- **0% Idle CPU**: Native integration with Quickshell services ensures no unnecessary polling.
- **Sanitized Services**: High-level wrappers for `Audio`, `Mpris`, `UPower`, and `Network`.
- **Pure Quickshell**: No external legacy libraries or forked artifacts; a clean, from-scratch implementation.

## Contributions & Credits
HyprUI is built upon the foundation of modern Linux desktop innovation. Special thanks to the following projects:

- **Caelestial Shell**: This project's architecture and visual language were heavily inspired by the Caelestial shell dotfiles. The sidebar layout and theme cycling logic owe their heritage to the incredible work of the Caelestial community.
https://github.com/caelestia-dots/shell
- **Quickshell**: For providing the powerful reactive framework that makes this shell possible.

---

