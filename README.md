# DX-CLIP Demo

## Screenshot
*Real-time text-video similarity matching powered by CLIP on DeepX NPU*

![DX-CLIP Demo](img/dx_clip_demo_demoplay.gif)

---

## Overview

DX-CLIP Demo is a real-time video understanding application powered by the [CLIP](https://github.com/openai/CLIP) (Contrastive Language–Image Pretraining) model accelerated on DeepX NPU hardware.

The application matches live video frames against user-defined text sentences, displaying similarity scores in real time. It supports single-channel and multi-channel modes (up to 16 simultaneous video streams).

### Key Features

- Real-time text-video similarity scoring using CLIP
- Single-channel and multi-channel (up to 16 channels) video input
- Camera input support
- DeepX NPU-accelerated inference via `.dxnn` model
- Configurable display options (score, percentage, font, FPS, fullscreen, dark theme)

---

## Variants

### OpenCV

A lightweight, terminal-driven variant using OpenCV for video rendering.

- Minimal UI — output is rendered directly onto video frames using OpenCV
- Interactive text input via terminal (add/delete sentences at runtime)
- Suitable for headless or embedded environments
- Venv: `venv-opencv`

→ See [README-opencv.md](README-opencv.md) for setup and usage.

---

### PyQT5

A full-featured GUI variant built with the PyQT5 UI framework.

- Rich settings panel: assets path, channel count, FPS sync, fullscreen, dark theme, font layout options
- Multi-channel grid view with configurable center grid merge
- Camera mode for live input alongside video channels
- Venv: `venv-pyqt`

→ See [README-pyqt.md](README-pyqt.md) for setup and usage.

---

## Quick Start

One command does everything — it prompts you to pick the variant
(`pyqt` or `opencv`), downloads models/videos, creates the venv, and
launches the demo:

```bash
./run_demo.sh
```

Skip the prompt by passing the variant:

```bash
./run_demo.sh --app_type=opencv   # or --app_type=pyqt
```

The first run invokes `setup.sh` automatically, which also downloads and builds
**dx-runtime** if it isn't already present. To set up manually instead:

```bash
# dx-runtime is auto-cloned when missing; pass --dxrt_src_path to reuse an existing checkout
./setup.sh --app_type=pyqt
source venv-pyqt/bin/activate
python -m clip_demo_app_pyqt.dx_realtime_demo_pyqt
```
