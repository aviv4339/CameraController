<h1 align="center"> CameraController </h1>

<!-- subtext -->
<div align="center">
Control your camera's settings on macOS — exposure, focus, white balance and more —
without the vendor's software. Now with full <b>Razer Kiyo Pro</b> support (HDR, Field of View, autofocus).
</div>

<br/>

<!-- shields -->
<div align="center">
    <!-- downloads -->
    <a href="https://github.com/aviv4339/CameraController/releases">
        <img src="https://img.shields.io/github/downloads/aviv4339/CameraController/total" alt="downloads"/>
    </a>
    <!-- version -->
    <a href="https://github.com/aviv4339/CameraController/releases/latest">
        <img src="https://img.shields.io/github/release/aviv4339/CameraController.svg" alt="latest version"/>
    </a>
    <!-- license -->
    <a href="https://github.com/aviv4339/CameraController/blob/master/License.txt">
        <img src="https://img.shields.io/github/license/aviv4339/CameraController.svg" alt="license"/>
    </a>
    <!-- platform -->
    <a href="https://github.com/aviv4339/CameraController">
        <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="platform"/>
    </a>
</div>

<br/>

<div align="center">
    <img src="./.github/Basic.png" width="299" alt="basic screenshot"/>
    <img src="./.github/Preferences.png" width="299" alt="preferences screenshot"/>
</div>

<br/>

> This is a fork of [itaybre/CameraController](https://github.com/itaybre/CameraController) that adds
> **Razer Kiyo Pro** vendor controls, a **Gamma** and dedicated **Gain** slider, **apply-on-startup**,
> and fixes a descriptor-parsing bug that prevented some cameras (including the Kiyo Pro on Apple Silicon)
> from working at all.

## Features

- **Image** — brightness, contrast, saturation, sharpness, hue, **gamma**, white balance (auto/manual)
- **Exposure** — auto/manual exposure, exposure time, **gain**
- **Lens & orientation** — focus (auto/manual), zoom, pan/tilt, roll
- **Other UVC controls** — power-line frequency (anti-flicker), backlight compensation
- **Live preview** so you can see adjustments in real time
- **Profiles** — save and instantly re-apply named setting presets
- **Apply on startup** — re-applies your last-used settings when a camera reconnects
- **Menu-bar app** with an optional detachable preview window

### 🎥 Razer Kiyo Pro

The Kiyo Pro's Synapse-exclusive features are exposed directly, no Windows required:

| Control | Options |
| --- | --- |
| **HDR** | On / Off |
| **HDR Mode** | Dark / Bright |
| **Field of View** | Wide / Medium / Narrow |
| **Autofocus** | Responsive / Passive |
| **Save to Camera** | Persist HDR/FoV/AF to the camera so they survive unplug & reboot |

The Razer section appears in the **Advanced** tab only when a compatible extension unit is detected.

## Installation

Download the latest `.zip` from [Releases](https://github.com/aviv4339/CameraController/releases/latest),
unzip, and move `CameraController.app` to your Applications folder.

> The build is not notarized, so on first launch macOS Gatekeeper will block it. **Right-click the app → Open**,
> then confirm — you only need to do this once.

On first run, grant **camera access** when prompted (needed for the live preview);
control also requires access to the USB device.

## FAQ

**Does it work with Apple's FaceTime / built-in camera?**
No. Newer Macs (T1/T2/Apple Silicon) restrict control of the built-in camera to Apple. Use an external UVC camera.

**My camera shows "Unsupported" or no controls appear.**
Make sure you've selected the external camera in **Settings → Camera** (not the built-in one). If a UVC camera
still shows nothing, please open an issue with the model.

**The preview is black.**
Grant camera permission in **System Settings → Privacy & Security → Camera**.

## Support

- macOS 12 (Monterey) and up.
- Works with cameras controllable via [UVC](https://www.usb.org/document-library/video-class-v15-document-set),
  including Apple Silicon.

## How to build

Requires **Xcode** and [SwiftLint](https://github.com/realm/SwiftLint).

```sh
git clone https://github.com/aviv4339/CameraController.git
cd CameraController
open CameraController.xcodeproj
```

Build & run the `CameraController` scheme.

For troubleshooting vendor commands you can enable verbose USB logging:

```sh
defaults write com.itaysoft.CameraController uvcVerboseLogging -bool YES
```

## Credits

- Original project by [@itaybre](https://github.com/itaybre)
- Icons by [@herrerajeff](https://github.com/herrerajeff)
- Razer Kiyo Pro protocol reference: [soyersoyer/kiyoproctrls](https://github.com/soyersoyer/kiyoproctrls)
- This fork maintained by [@aviv4339](https://github.com/aviv4339)

## License

Same license as the upstream project — see [License.txt](License.txt).
