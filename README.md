# Garmin Watch Face – Chronograph

A Tissot-inspired chronograph watch face for the **Garmin Fenix 8 47mm**, built with [Connect IQ](https://developer.garmin.com/connect-iq/) and Monkey C.

![Design reference](tissot.png)

## Features

- Dark gunmetal tachymetre bezel with white tick marks
- White main dial with baton hour markers
- Three charcoal sub-dials:
  - **Top** — minutes (0–60) with blue accent ticks at 20 and 40
  - **Bottom-left** — hours (12h format)
  - **Bottom-right** — seconds (0–60)
- Orange center seconds hand with lollipop counterbalance tail
- Dark hands with white luminous center strips
- Date window positioned between minute marks 16–17 (≈ 3 o'clock)
- Optimised for AMOLED — true black background saves battery

## Requirements

| Tool | Version |
|------|---------|
| [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) | 4.0.0+ |
| Target device | Garmin Fenix 8 47mm (`fenix847mm`) |
| VS Code extension | [Monkey C](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c) |

## Setup

**1. Install the SDK**

Download the Connect IQ SDK Manager from [developer.garmin.com/connect-iq/sdk](https://developer.garmin.com/connect-iq/sdk/) and install the SDK. The `.vscode/settings.json` in this repo points to:

```
~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-<version>/
```

Update the path if your SDK is installed elsewhere.

**2. Generate a developer key** (needed for sideloading to a physical device)

```bash
openssl genrsa -out ~/.Garmin/developer_key 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
  -in ~/.Garmin/developer_key \
  -out ~/.Garmin/developer_key.der -nocrypt
```

**3. Build**

```bash
monkeyc \
  -f monkey.jungle \
  -o bin/garmin-skin.prg \
  -y ~/.Garmin/developer_key.der \
  -d fenix847mm \
  -w
```

## Running in the simulator

```bash
# Start the simulator
connectiq &

# Push the compiled app to it
monkeydo bin/garmin-skin.prg fenix847mm
```

Add the SDK `bin/` directory to your `PATH` to avoid typing the full path each time:

```bash
export PATH="$PATH:$HOME/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-<version>/bin"
```

## Project structure

```
├── source/
│   └── WatchFace.mc          # Main watch face implementation
├── resources/
│   ├── bitmaps.xml           # Launcher icon declaration
│   ├── images/icon.png       # Launcher icon (replace with 65×65px)
│   ├── strings/strings.xml   # App name string
│   └── drawables/
├── manifest.xml              # App metadata, targets fenix847mm
├── monkey.jungle             # Build configuration
└── .vscode/settings.json     # SDK path for VS Code Monkey C extension
```

## Sideloading to the watch

Connect your Fenix 8 via USB and copy the compiled file:

```bash
cp bin/garmin-skin.prg /media/<user>/GARMIN/GARMIN/APPS/
```

Or use the Connect IQ app on your phone to install directly from Garmin's Connect IQ Store once published.
