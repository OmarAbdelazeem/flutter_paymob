# iOS Paymob “Please wait / Don’t close this page” Troubleshooting

This document explains the common causes and fixes for an issue where the **Paymob / Accept SDK UI on iOS** gets stuck on a white screen showing a dialog like:

> “Please wait  
> Don’t close this page.”

Use this as a handover for any AI agent or developer integrating the saved-cards feature and Paymob SDK in another Flutter project.

---

## 1. Reference implementation (working plugin)

The working iOS implementation lives in `packages/paymob_flutter_lib/ios/Classes/SwiftPaymobFlutterLibPlugin.swift`.

Key points:

- Class: `SwiftPaymobFlutterLibPlugin : NSObject, FlutterPlugin, AcceptSDKDelegate`
- Holds a stored result: `var flutterResult: FlutterResult?`
- Uses a single `AcceptSDK` instance: `let accept = AcceptSDK()` and sets `accept.delegate = self` in `init`.

### 1.1 How the Paymob UI is presented

#### Entry point from Flutter

```swift
public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    flutterResult = result
    switch call.method {
    case "StartPayActivityNoToken":
        guard let args = call.arguments as? [String: Any],
              let paymentStr = args["payment"] as? String else {
            print("[Paymob iOS] StartPayActivityNoToken: missing payment argument")
            finishWithError(
                errorCode: "MISSING_ARGUMENT",
                errorMessage: "Missing Argument == ",
                details: String(describing: call.arguments)
            )
            return
        }
        let payment = try! JSONDecoder().decode(Payment.self, from: Data(paymentStr.utf8))
        print("[Paymob iOS] StartPayActivityNoToken: decoded payment, key length=\(payment.paymentKey?.count ?? 0)")
        startPayActivityNoToken(result: result, payment: payment)

    case "StartPayActivityToken":
        // Similar shape: validate args, then call a token-based method
        ...

    default:
        result(FlutterMethodNotImplemented)
    }
}
```

#### Presenting the Accept SDK

```swift
private func startPayActivityNoToken(result: FlutterResult, payment: Payment) {
    do {
        let rootViewController: UIViewController! = UIApplication.shared.keyWindow?.rootViewController

        // Alternative (scene-based) root VC, currently unused:
        let sceneRootVC = UIApplication.shared.windows
            .first(where: { !$0.isHidden })?
            .rootViewController

        let paymentKey = payment.paymentKey ?? ""
        print("[Paymob iOS] presentPayVC: paymentKey length=\(paymentKey.count), country=Egypt, showSaveCard=\(payment.showSaveCard ?? false)")

        try accept.presentPayVC(
            vC: rootViewController,
            paymentKey: paymentKey,
            country: .Egypt,
            saveCardDefault: payment.saveCardDefault ?? false,
            showSaveCard: payment.showSaveCard ?? false,
            showAlerts: true,
            language: .English
        )
    } catch AcceptSDKError.MissingArgumentError(let errorMessage) {
        print("[Paymob iOS] MissingArgumentError: \(errorMessage)")
        // NOTE: this path only logs in the reference code; an improvement is to call finishWithError here as well.
    } catch let error {
        print("[Paymob iOS] presentPayVC error: \(error.localizedDescription)")
        // Same note as above.
    }
}
```

**Important details:**

- The plugin currently uses `UIApplication.shared.keyWindow?.rootViewController` as the VC passed into `presentPayVC`.
- On iOS 13+ with scenes, `keyWindow` can be `nil` or not the active window; a better root VC is often the first non-hidden window’s root VC (`sceneRootVC` above) or the top-most presented VC.

If the wrong VC is used, the Accept SDK might appear but never complete correctly or never deliver callbacks, which looks like the app is stuck on “Please wait”.

---

## 2. How results are returned to Flutter

The plugin stores the Flutter method-channel result in `flutterResult` and always uses that in callbacks.

### 2.1 Stored result

```swift
var flutterResult: FlutterResult?
```

Set in `handle`:

```swift
flutterResult = result
```

### 2.2 Success and error helpers

```swift
private func finishWithSuccess(msg: String) {
    print("[Paymob iOS] finishWithSuccess")
    flutterResult?(msg)
}

private func finishWithError(errorCode: String, errorMessage: String, details: String) {
    print("[Paymob iOS] finishWithError: code=\(errorCode), message=\(errorMessage), details=\(details)")
    flutterResult?(FlutterError(code: errorCode, message: errorMessage, details: nil))
}
```

### 2.3 AcceptSDK delegate methods

```swift
public func userDidCancel() {
    print("[Paymob iOS] userDidCancel")
    finishWithError(
        errorCode: "USER_CANCELED",
        errorMessage: "User canceled!!!",
        details: ""
    )
}

public func paymentAttemptFailed(_ error: AcceptSDKError, detailedDescription: String) {
    print("[Paymob iOS] paymentAttemptFailed: \(error.localizedDescription), details: \(detailedDescription)")
    finishWithError(
        errorCode: "TRANSACTION_ERROR",
        errorMessage: "Reason == " + error.localizedDescription,
        details: detailedDescription
    )
}

public func transactionRejected(_ payData: PayResponse) {
    print("[Paymob iOS] transactionRejected: \(payData.dataMessage)")
    finishWithError(
        errorCode: "TRANSACTION_REJECTED",
        errorMessage: payData.dataMessage,
        details: ""
    )
}

public func transactionAccepted(_ payData: PayResponse) {
    let paymentResult = try! JSONEncoder().encode(
        PaymentResult(
            dataMessage: payData.dataMessage,
            token: "",
            maskedPan: "",
            id: String(payData.id)
        )
    )
    let jsonString = String(data: paymentResult, encoding: .utf8) ?? ""
    finishWithSuccess(msg: jsonString)
}

public func transactionAccepted(_ payData: PayResponse, savedCardData: SaveCardResponse) {
    let paymentResult = try! JSONEncoder().encode(
        PaymentResult(
            dataMessage: payData.dataMessage,
            token: savedCardData.token,
            maskedPan: savedCardData.masked_pan,
            id: String(payData.id)
        )
    )
    let jsonString = String(data: paymentResult, encoding: .utf8) ?? ""
    finishWithSuccess(msg: jsonString)
}

public func userDidCancel3dSecurePayment(_ pendingPayData: PayResponse) {
    print("[Paymob iOS] userDidCancel3dSecurePayment: \(pendingPayData.dataMessage)")
    finishWithError(
        errorCode: "USER_CANCELED_3D_SECURE_VERIFICATION",
        errorMessage: "User canceled 3-d scure verification!!",
        details: pendingPayData.dataMessage
    )
}
```

**Important:** Every success/error/cancel/3DS-cancel delegate path ends up calling `finishWithSuccess` or `finishWithError`, which in turn call **`flutterResult?(...)`**. That means the Dart side always receives a completion for `startPayActivityNoToken` / `startPayActivityToken`, unless:

- An exception is thrown **before** the SDK is presented and is only logged (not forwarded to Flutter), or
- The plugin in another project has diverged and no longer calls `result` in all paths.

---

## 3. Common causes of “stuck on Please wait” in another project

When porting this plugin or re‑implementing it, pay special attention to these pitfalls:

### 3.1 Wrong or invisible view controller

Symptoms:

- The Paymob page appears with “Please wait / Don’t close this page” and never completes.
- No AcceptSDK delegate methods are logged or called.

Potential causes:

- Using `UIApplication.shared.keyWindow` on iOS 13+ can return `nil` or a background window.
- Presenting from a VC that is not part of the visible hierarchy.

Fix:

- Use a visible scene’s root VC, for example:

  ```swift
  let rootVC = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?
      .rootViewController
  ```

  Or use the first non-hidden window’s root VC and then climb to the top-most presented controller.
- Pass that VC into `presentPayVC`.

### 3.2 Not always calling `result` / `flutterResult`

Symptoms:

- Dart/Flutter `await startPayActivityNoToken(...)` never completes.
- iOS UI may show “Please wait” or an error but Flutter doesn’t know.

Potential causes:

- An error branch (e.g. JSON decode failure, `presentPayVC` throw) only logs and returns without calling `result(...)`.
- One of the AcceptSDK delegate methods is missing or doesn’t call `finishWithSuccess/finishWithError`.
- `flutterResult` is overwritten by a second call before the first one completes.

Fix:

- In the other project’s plugin, search for:
  - All `catch` blocks around `presentPayVC` and decoding.
  - Every `AcceptSDKDelegate` method.
- Ensure that **every path** that represents a terminal outcome (success, failure, cancellation, invalid params) calls either:

  ```swift
  result(...)
  // or
  flutterResult?(...)
  ```

  so that the Dart side always gets a completion.

### 3.3 Delegate not wired

Symptoms:

- You see the Paymob UI, but **no** delegate method is ever called.

Potential causes:

- `accept.delegate = self` is missing or executed on a different instance.
- The plugin instance that presented the SDK is deallocated before callbacks fire.

Fix:

- Ensure `accept.delegate = self` is set in `init` and that the same `accept` instance is used for presenting the VC.
- Make sure the plugin instance is retained by Flutter (as in the reference `register(with:)`).

### 3.4 Country / configuration mismatch

Symptoms:

- The SDK shows generic “Error processing payment” or remains in an intermediate state.

Potential causes:

- Using the wrong `country` enum (e.g. `.Pakistan` instead of `.Egypt`) for your merchant configuration.

Fix:

- Match the `country` parameter in `presentPayVC` to the merchant’s region (e.g. `.Egypt`).

---

## 4. Checklist for other projects

When your iOS integration is stuck on “Please wait / Don’t close this page”, verify:

1. **View controller**
   - The VC passed into `presentPayVC` is from a visible window/scene.
2. **Result handling**
   - `flutterResult` (or equivalent) is stored when `handle` is called.
   - Every terminal path (success, reject, fail, user cancel, 3DS cancel, invalid args, presentPayVC error) calls `flutterResult?(...)`.
3. **Delegate wiring**
   - `accept.delegate = self` is set.
   - All relevant `AcceptSDKDelegate` methods are implemented and call `finishWithSuccess/finishWithError`.
4. **Configuration**
   - `country` matches your merchant region (e.g. `.Egypt`).
   - Payment key (`paymentKey`) is non-empty and valid.

If an AI agent is implementing this feature in another project, they should use this document together with the original plugin (`SwiftPaymobFlutterLibPlugin`) as the reference for a correct, non‑blocking iOS integration.

