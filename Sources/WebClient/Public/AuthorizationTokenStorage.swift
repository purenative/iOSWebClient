public protocol AuthorizationTokenStorage {
    
    func update(accessToken: String, refreshToken: String?)
    func getToken(byType tokenType: TokenType) -> String?
    
}
