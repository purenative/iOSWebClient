public struct AuthorizationMethodRuleParameters {
    
    public let route: String
    public let method: HTTPMethod
    
    public init(route: String,
                method: HTTPMethod) {
        
        self.route = route
        self.method = method
    }
    
}
