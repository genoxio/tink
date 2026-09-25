import Foundation
import Capacitor
import os
import UIKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(TinkPlugin)
public class TinkPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "TinkPlugin"
    public let jsName = "Tink"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "openTink", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "handleOpenUrl", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "dismissTink", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = Tink.shared
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.tink.plugin",
        category: "TinkPlugin"
    )

    @objc func openTink(_ call: CAPPluginCall) {
        let rawOptions = (call.options ?? [:]) as [AnyHashable: Any]
        let stringOptions = rawOptions.reduce(into: [String: Any]()) { result, entry in
            let key = String(describing: entry.key)
            result[key] = entry.value
        }
        let options = TinkLinkOptions.from(capacitorOptions: stringOptions)

        guard let viewController = self.bridge?.viewController else {
            call.reject("No view controller available to present the Tink flow")
            return
        }

        implementation.openTink(options: options, from: viewController) { result in
            call.resolve(result)
        }
    }

    @objc func handleOpenUrl(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"), let url = URL(string: urlString) else {
            call.reject("Missing or invalid url")
            return
        }

        let result = implementation.handleOpenURL(url)
        call.resolve(result)
    }

    @objc func dismissTink(_ call: CAPPluginCall) {
        let result = implementation.dismissTink(from: self.bridge?.viewController)
        call.resolve(result)
    }
}
