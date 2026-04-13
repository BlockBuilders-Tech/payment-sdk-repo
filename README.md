
# Payment SDK – Flutter Module

A Flutter module that provides a drop-in payment WebView for native **Android** and **iOS** host apps.

## Architecture

```
Host App (Android / iOS)
  └── FlutterEngine
        └── PaymentWidget.startPayment(config)
              └── PaymentScreen (WebView → pay.blockbuilders.ps)
                    ├── JS channel callback  → PaymentResult
                    ├── URL-scheme redirect  → PaymentResult
                    └── User cancels         → PaymentResult
```

## Files

| File | Purpose |
|---|---|
| `payment_config.dart` | Config model with validation |
| `payment_result.dart` | Result model (success / error / cancel) |
| `payment_screen.dart` | WebView screen with JS bridge |
| `payment_widget.dart` | Public API – `PaymentWidget.startPayment()` |
| `payment_sdk.dart` | Barrel export |
| `main.dart` | Demo / test runner app |

---

## Build AARs for Android

```bash
cd payment_sdk
flutter build aar
```

This outputs AARs to `build/host/outputs/repo/`. In your Android host app:

**settings.gradle**
```groovy
dependencyResolutionManagement {
    repositories {
        maven { url '<path-to>/payment_sdk/build/host/outputs/repo' }
        maven { url 'https://storage.googleapis.com/download.flutter.io' }
    }
}
```

**app/build.gradle**
```groovy
dependencies {
    debugImplementation 'ps.blockbuilders.paymentSdk:flutter_debug:1.0'
    releaseImplementation 'ps.blockbuilders.paymentSdk:flutter_release:1.0'
}
```

Then in your Activity:

```kotlin
val engine = FlutterEngine(this)
engine.dartExecutor.executeDartEntrypoint(
    DartExecutor.DartEntrypoint.createDefault()
)
startActivity(
    FlutterActivity.withCachedEngine("payment_engine").build(this)
)
```

---

## Build Framework for iOS

```bash
cd payment_sdk
flutter build ios-framework --output=build/ios-frameworks
```

In Xcode, add the output `.xcframework` files to your target's **Frameworks, Libraries, and Embedded Content**.

Then in your ViewController:

```swift
let engine = FlutterEngine(name: "payment_engine")
engine.run()
let vc = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
present(vc, animated: true)
```

---

## Usage from Flutter (demo / testing)

```dart
final result = await PaymentWidget.startPayment(
  context: context,
  config: PaymentConfig(
    ereference: 'ORDER_123',
    token: 'your_server_token',
    url: 'https://your-site.com/callback',
    lang: 'ar',  // optional, defaults to 'en'
  ),
);

if (result.isSuccess) {
  print('Paid! ${result.data}');
} else if (result.isCancelled) {
  print('User cancelled');
} else {
  print('Error: ${result.message}');
}
```

---

## How Results Come Back

The SDK supports three callback mechanisms (whichever fires first wins):

1. **JS Channel** – The payment page calls `PaymentChannel.postMessage(JSON.stringify({status, message}))`.
2. **Custom Event** – The page dispatches a `payment-result` CustomEvent; the injected bridge forwards it.
3. **URL Scheme** – The page redirects to `payment-success://`, `payment-cancel://`, or `payment-error://`.

---

## Running Tests

```bash
flutter test
```