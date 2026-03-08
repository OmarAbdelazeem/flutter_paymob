import Flutter
import UIKit
import AcceptSDK

public class SwiftPaymobFlutterLibPlugin: NSObject, FlutterPlugin,AcceptSDKDelegate {
    var flutterResult : FlutterResult?
    let accept = AcceptSDK()
    override init() {
        super.init()
        accept.delegate = self
    }
    struct PaymentResult: Codable{ 
        let dataMessage: String?
        let token: String?
        let maskedPan: String?
        let id: String?
        
        enum CodingKeys: String, CodingKey {
            case dataMessage = "data_message"
            case token = "token"
            case maskedPan = "masked_pan"
            case id = "id"
        }
    }
    struct Payment: Codable{
        let paymentKey: String?
        let saveCardDefault: Bool?
        let showSaveCard: Bool?
        let themeColor: String?
        let language: String?
        let actionbar: Bool?
        let token: String?
        let maskedPanNumber: String?
        let customer: Customer?
        
        enum CodingKeys: String, CodingKey {
            case paymentKey = "payment_key"
            case saveCardDefault = "save_card_default"
            case showSaveCard = "show_save_card"
            case themeColor = "theme_color"
            case language = "language"
            case actionbar = "actionbar"
            case token = "token"
            case maskedPanNumber = "masked_pan_number"
            case customer = "customer"
        }
    }
    struct Customer: Codable{
        let firstName: String?
        let lastName: String?
        let building: String?
        let floor: String?
        let apartment: String?
        let city: String?
        let state: String?
        let country: String?
        let email: String?
        let phoneNumber: String?
        let postalCode: String?
        
        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case building = "building"
            case floor = "floor"
            case apartment = "apartment"
            case city = "city"
            case state = "state"
            case country = "country"
            case email = "email"
            case phoneNumber = "phone_number"
            case postalCode = "postal_code"
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "paymob_flutter_lib", binaryMessenger: registrar.messenger())
        let instance = SwiftPaymobFlutterLibPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterResult = result
        switch call.method {
            case "StartPayActivityNoToken":
                guard let args = call.arguments as? Dictionary<String, Any>,
                      let paymentStr = args["payment"] as? String else {
//                        result(FlutterError(code: "payment_args", message: "invalid arguments", details: call.arguments))
                    finishWithError(errorCode: "MISSING_ARGUMENT", errorMessage: "Missing Argument == ", details: call.arguments as! String);

                        return
                }
                let paymentt = try! JSONDecoder().decode(Payment.self,from: Data(paymentStr.utf8))
            
                self.startPayActivityNoToken(result: result,payment: paymentt)
            case "StartPayActivityToken":
              guard let args = call.arguments as? [String: Any],
                    let _ = args["payment"] as? String else {
                  result(FlutterError(code: "payment_args", message: "invalid arguments", details: call.arguments))
                  return
              }
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    private func startPayActivityNoToken(result: FlutterResult,payment: Payment) {
        do {
            let rootViewController:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
            
            let rootViewControllerr = UIApplication.shared.windows.filter({ (w) -> Bool in
                        return w.isHidden == false
             }).first?.rootViewController

            try accept.presentPayVC(vC: rootViewController, paymentKey: payment.paymentKey ?? "", country: .Pakistan, saveCardDefault: payment.saveCardDefault ?? false, showSaveCard: payment.showSaveCard ?? false, showAlerts: true, language: .English)
        } catch AcceptSDKError.MissingArgumentError(let errorMessage) {
            print(errorMessage)
        }  catch let error {
            print(error.localizedDescription)
        }
      
        // result("abcabc")
    }
    public func userDidCancel() {
        finishWithError(errorCode: "USER_CANCELED", errorMessage: "User canceled!!!", details: "");
    }
    
    public func paymentAttemptFailed(_ error: AcceptSDKError, detailedDescription: String) {
        finishWithError(errorCode: "TRANSACTION_ERROR",errorMessage:  "Reason == " + error.localizedDescription,details:  detailedDescription);

    }
    
    public func transactionRejected(_ payData: PayResponse) {
        finishWithError(errorCode: "TRANSACTION_REJECTED",errorMessage:  payData.dataMessage, details: "");

    }
    
    public func transactionAccepted(_ payData: PayResponse) {
        let paymentResult = try! JSONEncoder().encode(PaymentResult(dataMessage: payData.dataMessage,token: "", maskedPan: "",id : String(payData.id)))
        let jsonString = String(data: paymentResult, encoding: .utf8) ?? ""
        finishWithSuccess(msg: jsonString)
    }
    
    public func transactionAccepted(_ payData: PayResponse, savedCardData: SaveCardResponse) {
        let paymentResult = try! JSONEncoder().encode(PaymentResult(dataMessage: payData.dataMessage,token: savedCardData.token, maskedPan: savedCardData.masked_pan,id : String(payData.id)))
        let jsonString = String(data: paymentResult, encoding: .utf8) ?? ""
        finishWithSuccess(msg: jsonString)
    }
    
    public func userDidCancel3dSecurePayment(_ pendingPayData: PayResponse) {
        finishWithError(errorCode: "USER_CANCELED_3D_SECURE_VERIFICATION", errorMessage: "User canceled 3-d scure verification!!", details: pendingPayData.dataMessage);

    }
    private func finishWithSuccess(msg: String) {
        flutterResult!(msg);
    }

    private func finishWithError(errorCode: String, errorMessage: String, details:String) {
        flutterResult!(FlutterError(code: errorCode, message: errorMessage, details: nil))
    }
}
