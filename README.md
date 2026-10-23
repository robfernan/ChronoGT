# 🏎️ ChronoGT — Racing Tachometer Watch Face for Garmin Connect IQ

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Garmin%20Connect%20IQ-007CC3?style=for-the-badge&logo=garmin&logoColor=white" alt="Garmin Connect IQ" />
  <img src="https://img.shields.io/badge/SDK-Connect%20IQ%209.3.0-FFAA00?style=for-the-badge" alt="SDK 9.3.0" />
  <img src="https://img.shields.io/badge/Language-Monkey%20C-FF2200?style=for-the-badge" alt="Monkey C" />
  <img src="https://img.shields.io/badge/YouTube-60s%20Demo-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube Demo" />
  <img src="https://img.shields.io/badge/License-MIT-00FF66?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Supported%20Models-94%20Watches-lightgrey?style=for-the-badge" alt="94 Models" />
</p>

<p align="center">
  <strong>A clean, motorsport-inspired digital & analog watch face paying homage to 90s JDM instrument clusters and Gran Turismo tachometers.</strong>
</p>

<p align="center">
  <a href="https://youtube.com/shorts/R3h-WX0FZ2w">
    <img src="preview.gif" alt="ChronoGT Watch Face Animated Live Preview on Garmin Venu 3" width="460" />
  </a>
  <br />
  <sub>▶️ <em>Click above or <a href="https://youtube.com/shorts/R3h-WX0FZ2w">watch the full 60-second live demonstration on YouTube Shorts</a></em></sub>
</p>


---

## ✨ Features

- **240° Sweeping Racing Tachometer Gauge:**
  - Smooth outer gauge arc (`210°` to `330°` clockwise) with a designated **Redline Zone** (`75%–100%`) and hardware anti-aliasing.
  - Sweeping perimeter needle indicating live seconds without cluttering the center display.
- **Sequential 5-LED Shift Lights:**
  - F1 / JDM progressive shift indicator (`Green → Green → Amber → Amber → Redline`) that illuminates dynamically as the seconds hand approaches the redline.
- **Instant-Read Telemetry Dashboard:**
  - **Top:** Day of week & date (`FRI 23`)
  - **Center:** Crisp oversized digital time (`HH:MM`, 12h/24h aware) + live `:SS` seconds counter
  - **Bottom:** Battery `%` (turns redline at `≤ 20%`), live Heart Rate (`BPM`), and `STEPS` with an integrated step-goal progress bar
- **Signature JDM Phosphor Amber Cluster Styling:**
  - Precision `#FFAA00` phosphor warm instrument cluster glow with high-contrast `#FF2200` redline accents.
- **AMOLED Always-On Display (AOD) Burn-In Safe:**
  - Micro-pixel drift mode (`onEnterSleep`) to prevent screen burn-in on AMOLED displays while preserving battery life.
- **Exceptional Memory & Battery Efficiency:**
  - **Only 3.5 KB runtime memory footprint** (0.45% of available watch RAM).
  - 100% vector mathematics (`dc.drawArc()`, `dc.fillPolygon()`) with zero heavy raster backgrounds.

---

## ⌚ Supported Garmin Devices (94 Round Color Models)

Pre-compiled and certified in `bin/ChronoGT.iq` across 94 round color Garmin watches (Connect IQ 3.2+), including:
- **Venu Series:** Venu 3, Venu 3S, Venu 2, Venu 2 Plus, Venu 2S, Venu, Venu Sq 2
- **Fēnix Series:** fēnix 8 (43mm/47mm/51mm/Solar), fēnix 7/7 Pro/7S/7X, fēnix 6/6 Pro/6S/6X, fēnix 5 Plus
- **Forerunner Series:** Forerunner 965, 265, 265S, 955, 255, 255S, 745, 245
- **Epix Series:** epix (Gen 2), epix Pro (42mm/47mm/51mm)
- **MARQ & Approach:** MARQ Gen 2 (Athlete, Aviator, Captain, Commander, Golfer), Approach S70, Approach S62
- **Vívoactive & Enduro:** vívoactive 5, vívoactive 4/4S, Enduro, Enduro 3

---

## 🚀 Installation & Sideloading

### Option 1: Garmin Connect IQ Store
Search for **ChronoGT Tachometer** directly inside the Garmin Connect IQ Store app on iOS or Android.

### Option 2: Direct Binary Sideload (.iq)
1. Download `ChronoGT.iq` from the [Latest GitHub Release](https://github.com/robfernan/ChronoGT/releases/latest).
2. Connect your Garmin watch to your computer via USB.
3. Place the extracted `.prg` for your device into the `GARMIN/APPS` folder on the watch storage.

---

## 🛠️ Developer Setup & Local Simulation

### Prerequisites
- Garmin Connect IQ SDK `9.3.0+`
- Developer RSA Key (`~/.Garmin/ConnectIQ/developer_key.der`)

### Build & Run
```bash
# Run locally in the Garmin Simulator
./run.sh venu3

# Build store package (.iq) supporting all 94 devices
monkeyc -e -r -f monkey.jungle -o bin/ChronoGT.iq -y ~/.Garmin/ConnectIQ/developer_key.der -w
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — see the LICENSE file for details.

---

## 👤 Author

**Robert Fernandez** — Cross-Platform Software Engineer & Digital Artist
- **Portfolio:** [robertfernandez.dev](https://robertfernandez.dev)
- **GitHub:** [@robfernan](https://github.com/robfernan)
