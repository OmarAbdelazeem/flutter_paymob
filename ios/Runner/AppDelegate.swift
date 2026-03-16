import Flutter
import UIKit
import PaymobSDK

@main
@objc class AppDelegate: FlutterAppDelegate, PaymobSDKDelegate {
  var SDKResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let window = self.window,
          let rootViewController = window.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let channel = FlutterMethodChannel(
      name: "paymob_sdk_flutter",
      binaryMessenger: rootViewController.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      if call.method == "payWithPaymob",
         let args = call.arguments as? [String: Any] {
        self.SDKResult = result
        self.callNativeSDK(arguments: args, vc: rootViewController)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func callNativeSDK(arguments: [String: Any], vc: FlutterViewController) {
    let paymob = PaymobSDK()
    paymob.delegate = self

    if let appName = arguments["appName"] as? String {
      paymob.paymobSDKCustomization.appName = appName
    }
    if let buttonBackgroundColor = arguments["buttonBackgroundColor"] as? NSNumber {
      let colorInt = buttonBackgroundColor.intValue
      let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
      let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
      let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
      let blue = CGFloat(colorInt & 0xFF) / 255.0
      paymob.paymobSDKCustomization.buttonBackgroundColor = UIColor(
        red: red, green: green, blue: blue, alpha: alpha
      )
    }
    if let buttonTextColor = arguments["buttonTextColor"] as? NSNumber {
      let colorInt = buttonTextColor.intValue
      let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
      let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
      let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
      let blue = CGFloat(colorInt & 0xFF) / 255.0
      paymob.paymobSDKCustomization.buttonTextColor = UIColor(
        red: red, green: green, blue: blue, alpha: alpha
      )
    }
    if let saveCardDefault = arguments["saveCardDefault"] as? Bool {
      paymob.paymobSDKCustomization.saveCardDefault = saveCardDefault
    }
    if let showSaveCard = arguments["showSaveCard"] as? Bool {
      paymob.paymobSDKCustomization.showSaveCard = showSaveCard
    }

    guard let publicKey = arguments["publicKey"] as? String,
          let clientSecret = arguments["clientSecret"] as? String else {
      SDKResult?("Rejected")
      SDKResult = nil
      return
    }

    do {
      try paymob.presentPayVC(VC: vc, PublicKey: publicKey, ClientSecret: clientSecret)
    } catch {
      print("[Paymob iOS] presentPayVC error: \(error.localizedDescription)")
      SDKResult?("Rejected")
      SDKResult = nil
    }
  }

  // MARK: - PaymobSDKDelegate

  public func transactionAccepted(transactionDetails: [String: Any]) {
    SDKResult?(["status": "Successfull", "details": transactionDetails])
    SDKResult = nil
  }

  public func transactionRejected(message: String) {
    SDKResult?("Rejected")
    SDKResult = nil
  }

  public func transactionPending() {
    SDKResult?("Pending")
    SDKResult = nil
  }
}
