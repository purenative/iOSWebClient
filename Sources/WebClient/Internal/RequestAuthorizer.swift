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
                request.addValue(method.preparedValue(using: accessToken),
                                 forHTTPHeaderField: method.preparedHeader())
            }
        }
        
    }
    
}
