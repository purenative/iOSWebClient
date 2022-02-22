import Foundation

public enum AuthorizationMethodRule {
    
    case none
    case include([AuthorizationMethodRuleParameters])
    case exclude([AuthorizationMethodRuleParameters])
    
    public func needAuthorizeMethod(_ method: HTTPMethod,
                                    atURL url: URL) -> Bool {
        
        switch self {
            
        case .none:
            return true
            
        case let .include(allParameters):
            for parameters in allParameters {
                if method == parameters.method && url.absoluteString.starts(with: parameters.route) {
                    return true
                }
            }
            return false
            
        case let .exclude(allParameters):
            for parameters in allParameters {
                if method == parameters.method && url.absoluteString.starts(with: parameters.route) {
                    return false
                }
            }
            return true
            
        }
        
    }
    
}
