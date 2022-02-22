public protocol AuthorizationMethod {
    
    var rule: AuthorizationMethodRule { get }
    func preparedHeader() -> String
    func preparedValue(using token: String?) -> String
    
}

extension AuthorizationMethod {
    
    public var rule: AuthorizationMethodRule {
        .none
    }
    
    public func preparedHeader() -> String {
        "Authorization"
    }
    
}
