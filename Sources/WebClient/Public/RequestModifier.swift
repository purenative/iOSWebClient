import Foundation

public protocol RequestModifier {
    
    func modify(_ request: inout URLRequest)
    
}
