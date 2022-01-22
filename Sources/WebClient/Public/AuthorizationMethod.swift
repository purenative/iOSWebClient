public protocol AuthorizationMethod {
    
    func preparedHeader() -> String
    func preparedValue(using token: String?) -> String
    
}

extension AuthorizationMethod {
    
    public func preparedHeader() -> String {
        "Authorization"
    }
    
}
