public protocol AccessTokenProvider {
    
    func provideToken(for webClient: WebClient,
                      refreshToken: String?) async -> AccessTokenProviderResult
    
}
