# Termax

A standalone terminal emulator for Android with Ubuntu environment. No Termux required.

## Features

- Full Ubuntu terminal on Android
- PRoot-based (no root required)
- Built-in terminal emulator with extra keys
- Storage access support

## Requirements

- Android 10+ (API 29)
- ~500MB free storage for Ubuntu rootfs
- Internet connection for first-time setup

## Installation

Download the latest APK from [Releases](https://github.com/keydelrey/termax/releases).

## First Run

1. Install the APK
2. Follow the setup wizard (downloads Ubuntu rootfs)
3. Start using the terminal!

## Building from Source

```bash
# Clone the repository
git clone https://github.com/keydelrey/termax.git
cd termax/flutter_app

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release
```

## Source Credits

This project is based on [openclaw-termux](https://github.com/mithun50/openclaw-termux) by Mithun Gowda B, used with permission under MIT License.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Keyy** - [GitHub](https://github.com/keydelrey)
