public protocol AccessTokenProvider {
    
    func provideToken(for webClient: WebClient) async -> AccessTokenProviderResult
    
}
