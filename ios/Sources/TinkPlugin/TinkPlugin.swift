import Foundation
import Capacitor
import os

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
        CAPPluginMethod(name: "openTink", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = Tink()
    private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
      category: "TinkPlugin"
  )

    

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func openTink(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.openTink(value)
        ])
        
    }
}
