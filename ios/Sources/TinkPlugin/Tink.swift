import Foundation

@objc public class Tink: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
