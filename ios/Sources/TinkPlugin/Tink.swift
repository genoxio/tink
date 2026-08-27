import Foundation

@objc public class Tink: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    
    @objc public func openTink(_ value: String) -> String {
        let val = "open tink ios"
        var value = val
        print(value)
        return value
    }
    
    
}
