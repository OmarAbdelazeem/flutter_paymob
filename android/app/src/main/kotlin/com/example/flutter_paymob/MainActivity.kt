package com.example.flutter_paymob

import android.graphics.Color
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.paymob.paymob_sdk.PaymobSdk
import com.paymob.paymob_sdk.ui.PaymobSdkListener

class MainActivity : FlutterActivity(), PaymobSdkListener {

    private val CHANNEL = "paymob_sdk_flutter"
    private var SDKResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "payWithPaymob") {
                SDKResult = result
                callNativeSDK(call)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun callNativeSDK(call: io.flutter.plugin.common.MethodCall) {
        val publicKey = call.argument<String>("publicKey")
        val clientSecret = call.argument<String>("clientSecret")
        if (publicKey == null || clientSecret == null) {
            SDKResult?.success("Rejected")
            SDKResult = null
            return
        }

        val appName = call.argument<String>("appName")
        val buttonBackgroundColorData = call.argument<Number>("buttonBackgroundColor")?.toInt()
        val buttonTextColorData = call.argument<Number>("buttonTextColor")?.toInt()
        val saveCardDefault = call.argument<Boolean>("saveCardDefault") ?: false
        val showSaveCard = call.argument<Boolean>("showSaveCard") ?: true

        var buttonBackgroundColor = Color.BLACK
        var buttonTextColor = Color.WHITE
        if (buttonBackgroundColorData != null) {
            buttonBackgroundColor = Color.argb(
                (buttonBackgroundColorData shr 24) and 0xFF,
                (buttonBackgroundColorData shr 16) and 0xFF,
                (buttonBackgroundColorData shr 8) and 0xFF,
                buttonBackgroundColorData and 0xFF
            )
        }
        if (buttonTextColorData != null) {
            buttonTextColor = Color.argb(
                (buttonTextColorData shr 24) and 0xFF,
                (buttonTextColorData shr 16) and 0xFF,
                (buttonTextColorData shr 8) and 0xFF,
                buttonTextColorData and 0xFF
            )
        }

        val paymobSdk = PaymobSdk.Builder(
            context = this,
            clientSecret = clientSecret,
            publicKey = publicKey,
            paymobSdkListener = this
        )
            .setButtonBackgroundColor(buttonBackgroundColor)
            .setButtonTextColor(buttonTextColor)
            .setAppName(appName)
            .showSaveCard(showSaveCard)
            .saveCardByDefault(saveCardDefault)
            .build()
        paymobSdk.start()
    }

    override fun onSuccess(payResponse: HashMap<String, String?>) {
        Log.d("Paymob", "onSuccess payResponse keys=${payResponse.keys}")
        Log.d("Paymob", "onSuccess payResponse=$payResponse")
        val details = payResponse.mapValues { (_, v) -> v }.filterValues { it != null }
        SDKResult?.success(mapOf("status" to "Successfull", "details" to details))
        SDKResult = null
    }

    override fun onFailure(msg: String?) {
        SDKResult?.success("Rejected")
        SDKResult = null
    }

    override fun onPending() {
        SDKResult?.success("Pending")
        SDKResult = null
    }
}
