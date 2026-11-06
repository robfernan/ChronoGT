# 🏎️ ChronoGT Tachometer — Motorsport Instrument Clusters for Garmin Connect IQ

<p align="center">
  <a href="https://apps.garmin.com/en-US/apps/a213d2da-0d13-4e02-ae58-3525fb89306a">
    <img src="https://img.shields.io/badge/Garmin%20Store-Live%20on%20Connect%20IQ-007CC3?style=for-the-badge&logo=garmin&logoColor=white" alt="Garmin Connect IQ Store" />
  </a>
  <a href="https://github.com/robfernan/ChronoGT">
    <img src="https://img.shields.io/badge/GitHub-robfernan%2FChronoGT-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Repository" />
  </a>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License" />
  <img src="https://img.shields.io/badge/Version-1.1.0-orange?style=for-the-badge" alt="Version 1.1.0" />
  <img src="https://img.shields.io/badge/Certified%20Models-159%20Watches-00CC66?style=for-the-badge&logo=garmin&logoColor=white" alt="159 Certified Models" />
</p>

<p align="center">
  <strong>Three iconic racing instrument clusters built with pure vector math for 159 certified Garmin watches. 100% free forever.</strong>
</p>

<p align="center">
  <a href="https://apps.garmin.com/en-US/apps/a213d2da-0d13-4e02-ae58-3525fb89306a">
    <strong>⬇️ Download Free on Garmin Connect IQ Store</strong>
  </a>
  &nbsp;•&nbsp;
  <a href="https://github.com/robfernan/ChronoGT">
    <strong>⭐ View Source on GitHub</strong>
  </a>
</p>

<p align="center">
  <img src="docs/assets/screen_1_classic.png" alt="Classic JDM Analog Layout on MARQ Captain" width="230" />
  <img src="docs/assets/screen_2_s2000.png" alt="Honda S2000 AP1 Layout on MARQ Captain" width="230" />
  <img src="docs/assets/screen_3_citroen.png" alt="1985 Citroën BX 19 Digit Layout on MARQ Captain" width="230" />
  <br />
  <sub><strong>Classic JDM Analog</strong> &nbsp;·&nbsp; <strong>Honda S2000 AP1</strong> &nbsp;·&nbsp; <strong>1985 Citroën BX 19 Digit</strong> (Rendered on MARQ Captain 240×240 MIP)</sub>
</p>

---

## 🏁 Overview

**ChronoGT Tachometer** is an open-source, motorsport-grade Garmin watch face paying homage to legendary analog and digital sports car instrument clusters. Originally launched on October 23, 2026, the **v1.1.0 Multi-Cluster update** (released November 5, 2026) expands the experience into 3 fully realized heritage dashboards with a native on-watch settings menu (`WatchUi.Menu2`).

- **100% Free Forever:** No paywalls, trial licenses, unlock keys, subscriptions, or ads.
- **Zero Heavy Bitmaps:** 100% procedural vector rendering (`dc.drawArc()`, `dc.fillPolygon()`) for lightning-fast refresh and ultra-low battery drain.
- **Micro Footprint:** Only **23 KB** package size on the Connect IQ store with minimal runtime heap usage—fitting easily into strict MARQ-class (~96 KiB) watch-face memory limits.
- **Universal Dynamic Geometry:** Fully adaptive layout engine calculating text boundaries dynamically via `dc.getTextDimensions()` to prevent overlaps across 218px, 240px, 260px, 280px, 360px, 390px, 416px, and 454px displays.
- **Hardware Verified:** Tested and validated on physical and simulated hardware across disparate display tech:
  - **MARQ Captain** (240×240, 64-color memory-in-pixel / MIP)
  - **Vívoactive 5** (390×390 AMOLED)
  - **Fēnix 8 47mm** (454×454 high-density AMOLED)

---

## 🏎️ Three Authentic Heritage Clusters

Switch between three iconic eras of automotive instrumentation on the fly:

| Cluster | Inspiration | Display Characteristics |
| :--- | :--- | :--- |
| **1. Classic JDM Analog** | 90s Japanese sports icons (Defi / RX-7 / GT-R) | 240° sweeping perimeter tachometer arc (`210°` to `330°`), dedicated redline zone, live sweeping second needle, sequential 5-LED shift pod, and centered digital speedometer. |
| **2. Honda S2000 AP1** | Formula-inspired 9,000 RPM high-revving roadster | Progressive climbing stepped tachometer curve, high-contrast digital speedo, and twin vertical flank bar gauges indicating **Battery %** ("engine temperature" metaphor) and **Steps vs Goal** ("fuel level" metaphor). *(Note: Telemetry represents native watch metrics, not vehicle ECU/OBD data).* |
| **3. 1985 Citroën BX 19 Digit** | Group B era French digital futurism | Dual nested neon tachometer arcs, retro Vacuum Fluorescent Display (VFD) bordered digital readout with glowing corner brackets, and satellite diagnostic tiles. |

---

## ✨ Features

- **Native On-Watch Settings (`WatchUi.Menu2`):**
  - Long-press the watch menu button to swap clusters, toggle shift lights, change themes, choose primary gauge drive modes, or map telemetry slots right on your wrist without taking out your phone.
  - Seamless two-way synchronization between watch storage properties and Garmin Connect Mobile.
- **Sequential 5-LED Shift Lights:**
  - Progressive F1/GT shift light pod (`Green → Green → Amber → Amber → Redline`) that illuminates dynamically as the driving metric approaches redline.
- **Configurable Primary Gauge Modes:**
  - **Live Seconds:** Sweeping second needle / rising tach arc.
  - **Steps vs. Goal:** Tachometer fills as you complete your daily step target.
  - **Live Heart Rate:** Dynamic tachometer driven by pulse with a high-intensity redline alert threshold.
- **Dual Telemetry Metric Slots:**
  - Two independently customizable data slots supporting: **Battery %**, **Daily Steps**, **Steps Remaining**, **Calories**, **Distance**, and **Live Heart Rate** (or **None** for a minimalist gauge).
- **Awake-Only Redline Pulse:**
  - Limiter flash triggers during seconds `:55–:59` when the watch is active/awake; strictly silenced during low-power sleep mode to save energy.
- **AMOLED Always-On Display (AOD) Burn-In Safe:**
  - Integrated micro-pixel sleep drift (`onEnterSleep`) preventing phosphor/pixel burn-in on AMOLED screens while maintaining glanceable time.

---

## 🎨 Heritage Colorways

Engineered with high-contrast palette values for both transflective MIP panels and vibrant AMOLED displays:

| Colorway | Hex Value | Visual Style |
| :--- | :--- | :--- |
| **JDM Amber** | `#FFAA00` | Classic 90s amber backlighting (Defi / NSX / Integra Type R) |
| **Redline Red** | `#FF2200` | Aggressive motorsport cockpit track instrumentation |
| **Track Cyan** | `#00CCFF` | Modern digital endurance racing HUD |
| **Tach Green** | `#00FF66` | Vintage phosphor and Le Mans telemetry display |

---

## 🏗️ Architecture & How It Works

```text
source/
├── ChronoGTApp.mc          # Application lifecycle, settings update delegate, Menu2 launcher
├── ChronoGTMetrics.mc      # Cached data provider (zero per-frame string allocations)
├── ChronoGTSettingsMenu.mc # WatchUi.Menu2 interface with real-time property writeback
└── ChronoGTView.mc         # Pure procedural vector drawing pipeline (Layouts 0, 1, 2)
```

1. **Procedural View Pipeline (`ChronoGTView.mc`):**
   - No raster images or sprite sheets are bundled in the runtime binary. Everything is drawn procedurally via `dc.drawArc()`, `dc.fillPolygon()`, and geometric math primitives.
   - Screen geometry is calculated relative to screen center `(cx, cy)` and screen radius `r`, allowing seamless scaling across any round Garmin bezel.
2. **Dynamic Typography Scaling:**
   - Instead of hardcoded offsets, font vertical metrics and bounding boxes are evaluated via `dc.getTextDimensions()` to anchor headers, speedo text, and telemetry indicators into guaranteed conflict-free vertical zones.
3. **Zero Allocations in Fast Path (`ChronoGTMetrics.mc`):**
   - Telemetry strings and sensor query states are cached and formatted only when metric values change, avoiding garbage collection spikes during high-frequency screen updates.
4. **Settings Sync Architecture:**
   - Properties are defined in `resources/settings/settings.xml`. When modified on the watch via `ChronoGTSettingsMenu.mc`, values are written directly to application properties, instantly triggering `onSettingsChanged()` in `ChronoGTApp.mc` and refreshing the view.

---

## ⌚ Supported Garmin Devices (159 Models)

ChronoGT Tachometer is compiled and certified in `manifest.xml` for **159 round color Garmin smartwatches** (Connect IQ 3.2+), including:

- **Fēnix Series:** fēnix 8 (43mm, 47mm, Solar 47mm, Solar 51mm, Pro 47mm), fēnix E, fēnix 7 / 7 Pro / 7S / 7X, fēnix 6 / 6 Pro / 6S / 6X, fēnix 5 Plus / 5S Plus / 5X Plus
- **Forerunner Series:** Forerunner 965, 265, 265S, 955, 255, 255S, 745, 245 / 245 Music, 165 / 165 Music, 170 / 170 Music
- **Venu Series:** Venu 3, Venu 3S, Venu 2, Venu 2 Plus, Venu 2S, Venu, Venu Mercedes-Benz, D2 Air, D2 Air X10
- **Epix Series:** epix (Gen 2), epix Pro (42mm, 47mm, 51mm)
- **MARQ Series (Gen 1 & Gen 2):** MARQ Athlete, Adventurer, Aviator, Captain, Commander, Golfer
- **Vívoactive & Enduro:** vívoactive 5, vívoactive 4 / 4S, Enduro, Enduro 3
- **Tactix, Descent & D2:** tactix 7, tactix Delta, tactix Charlie, Descent Mk2 / Mk2S / Mk3 (43mm, 51mm), Descent G2, D2 Mach 1, D2 Mach 2, D2 Mach 2 Pro

---

## ⚙️ Settings Reference

Settings can be toggled via **Garmin Connect Mobile** or the **On-Watch Menu** (long press watch `Menu` button):

| Setting Key | Options | Default | Description |
| :--- | :--- | :--- | :--- |
| **LayoutMode** | `Classic JDM Analog (0)`, `Honda S2000 AP1 (1)`, `Citroën BX 19 Digit (2)` | `0` | Selects active instrument cluster architecture |
| **AccentTheme** | `JDM Amber (0)`, `Redline Red (1)`, `Track Cyan (2)`, `Tach Green (3)` | `0` | Primary accent colorway |
| **GaugeMode** | `Live Seconds (0)`, `Steps vs Goal (1)`, `Heart Rate (2)` | `0` | Metric driving the primary tachometer arc/needle |
| **ShowShiftLights** | `Boolean` (`true` / `false`) | `true` | Enables progressive 5-LED shift light pod |
| **RedlinePulse** | `Boolean` (`true` / `false`) | `true` | Enables awake-only tach pulse during `:55–:59` |
| **MetricSlotA** | `Battery (0)`, `Steps (1)`, `Remaining (2)`, `Calories (3)`, `Distance (4)`, `HR (5)`, `None (6)` | `0` | Telemetry metric for Left/Top slot |
| **MetricSlotB** | `Battery (0)`, `Steps (1)`, `Remaining (2)`, `Calories (3)`, `Distance (4)`, `HR (5)`, `None (6)` | `5` | Telemetry metric for Right/Bottom slot |

---

## 🛠️ Building & Simulating from Source

### Prerequisites
1. **Garmin Connect IQ SDK 9.3.0+** installed.
2. A valid Garmin Developer RSA private key (`developer_key.der`).

### Build Store Binary (`.iq`)
To compile the universal distribution package:
```bash
monkeyc -e -r -f monkey.jungle -o bin/ChronoGT.iq -y ~/.Garmin/ConnectIQ/developer_key.der -w
```

### Launch in Simulator
Using the included test script (`scripts/run.sh`):
```bash
# Test on default target (venu3)
./scripts/run.sh

# Test on a specific watch model
./scripts/run.sh fenix847mm
./scripts/run.sh marqcaptain
./scripts/run.sh vivoactive5
```

---

## 📋 Changelog Highlights

### v1.1.0 (November 5, 2026) — *The Multi-Cluster Update*
- **3 Heritage Instrument Clusters:** Introduced Honda S2000 AP1 climbing curve and 1985 Citroën BX 19 Digit retro VFD alongside Classic JDM Analog.
- **Native On-Watch Settings (`WatchUi.Menu2`):** Direct wrist-based customization with bi-directional Garmin Connect Mobile property synchronization.
- **Universal Resolution-Adaptive Geometry:** Unified typography layout using `getTextDimensions` guaranteeing zero text overlap across all display sizes (218px to 454px).
- **Expanded Hardware Support:** Certified across **159 Garmin models** (up from 94).
- **Dual Telemetry Slots:** Configurable metric selection for slots A and B.
- **Awake Limiter Pulse:** Redline flash during `:55–:59` when awake; automatically disabled in low-power sleep mode.
- **AMOLED Sleep Drift:** Micro-pixel burn-in protection during low-power Always-On Display.

### v1.0.0 (October 23, 2026) — *Initial Release*
- Initial launch of ChronoGT 240° sweeping tachometer gauge, 5-LED shift lights, live health telemetry, and vector rendering engine.

---

## 📄 License & Credits

- **License:** Distributed under the [MIT License](LICENSE).
- **Author & Developer:** **Robert Fernandez** ([@robfernan](https://github.com/robfernan)) · Connect IQ Developer: **MungDaal321**
- **Website:** [robertfernandez.dev](https://robertfernandez.dev)
- **Garmin Store Page:** [ChronoGT Tachometer on Connect IQ](https://apps.garmin.com/en-US/apps/a213d2da-0d13-4e02-ae58-3525fb89306a)
