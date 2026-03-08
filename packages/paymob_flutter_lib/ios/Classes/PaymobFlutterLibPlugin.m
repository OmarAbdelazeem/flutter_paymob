#import "PaymobFlutterLibPlugin.h"
#if __has_include(<paymob_flutter_lib/paymob_flutter_lib-Swift.h>)
#import <paymob_flutter_lib/paymob_flutter_lib-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "paymob_flutter_lib-Swift.h"
#endif

@implementation PaymobFlutterLibPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaymobFlutterLibPlugin registerWithRegistrar:registrar];
}
@end
