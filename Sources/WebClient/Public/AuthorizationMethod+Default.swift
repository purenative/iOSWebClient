open class TokenBasedAuthorizationMethod: AuthorizationMethod {
    
    private let format: String
    
    public init(format: String) {
        self.format = format
    }
    
    public func preparedValue(using token: String?) -> String {
        guard let token = token else {
            return ""
        }

        return String(format: format, token)
    }
    
}

final public class TokenAuthorizationMethod: TokenBasedAuthorizationMethod {
    
    public init() {
        super.init(format: "Token %s")
    }
    
}

final public class BearerAuthorizationMethod: TokenBasedAuthorizationMethod {
    
    public init() {
        super.init(format: "Bearer %s")
    }
    
}

final public class JWTAuthorizationMethod: TokenBasedAuthorizationMethod {
    
    public init() {
        super.init(format: "JWT %s")
    }
    
}

final public class BasicAuthorizationMethod: AuthorizationMethod {
    
    private let username: String
    private let password: String
    
    public init(username: String,
                password: String) {
        
        self.username = username
        self.password = password
    }
    
    public func preparedValue(using token: String?) -> String {
        guard let basicToken = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
            return ""
        }
        
        return "Basic \(basicToken)"
    }
    
}
