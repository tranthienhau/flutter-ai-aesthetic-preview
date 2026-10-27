# Regenerating screenshots and demo GIFs

## Screenshots (iOS simulator)

```sh
xcrun simctl boot "iPhone 17 Pro"
flutter pub get
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
```

How it works: `integration_test/screenshot_test.dart` drives the app through a `ProviderContainer` it owns. It taps the age gate and consent boxes, uses `routerProvider` to jump between routes, and advances the demo clock to reach the paywall. At each stop it calls `binding.takeScreenshot('NN-name')`. `test_driver/integration_test.dart` writes each PNG to `screenshots/`. The generating screen runs an always-on scan animation, so the test pumps fixed durations instead of calling `pumpAndSettle`.

## Demo walkthrough

`integration_test/demo_test.dart` is a paced walkthrough with real taps, a slider drag and a before/after drag. Record it while it runs:

- iOS: `xcrun simctl io booted recordVideo --codec h264 demo.mp4`. If another host recording is already running, poll `xcrun simctl io <udid> screenshot` in a loop and stitch the frames with their timestamps.
- Android (device or emulator): `adb shell screenrecord --time-limit 55 --size 540x1200 /sdcard/ademo.mp4`, then `adb pull`.

```sh
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/demo_test.dart -d <device>
```

Convert each recording to a GIF with an ffmpeg palette pass (12 fps, 300 px wide).
