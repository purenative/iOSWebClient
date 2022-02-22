import Foundation

class RequestAuthorizer {
    
    private let authorizationMethods: [AuthorizationMethod]
    
    init(with authorizationMethods: [AuthorizationMethod]) {
        self.authorizationMethods = authorizationMethods
    }
    
    func authorizeRequest(_ request: inout URLRequest,
                          usingStorage storage: AuthorizationTokenStorage) {
        
        if let accessToken = storage.getToken(byType: .access) {
            for method in authorizationMethods {
                
                if let httpMethod = HTTPMethod(rawValue: request.httpMethod ?? ""), let url = request.url {
                    if method.rule.needAuthorizeMethod(httpMethod, atURL: url) {
            
                        request.setValue(method.preparedValue(using: accessToken),
                                         forHTTPHeaderField: method.preparedHeader())
                    }
                }
            }
        }
        
    }
    
}
