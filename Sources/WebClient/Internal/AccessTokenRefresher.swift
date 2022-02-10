actor AccessTokenRefresher {
    
    typealias Completion = () -> Void
    
    private let accessTokenStorage: AuthorizationTokenStorage
    private let accessTokenProvider: AccessTokenProvider
    
    private var refreshingCompletions = [Completion]()
    
    private(set) var lastRefreshingSuccessed: Bool = false
    
    private(set) var refreshing: Bool = false
    
    public init(withStorage accessTokenStorage: AuthorizationTokenStorage,
                andProvider accessTokenProvider: AccessTokenProvider) {
        
        self.accessTokenStorage = accessTokenStorage
        self.accessTokenProvider = accessTokenProvider
    }
    
    func waitOrRefreshToken(for webClient: WebClient) async -> Bool {
        if refreshing {
            await waitEndOfRefresh()
        } else {
            await refreshToken(for: webClient)
            #if DEBUG
            print("AccessTokenRefresher token refreshed:", lastRefreshingSuccessed)
            #endif
        }
        return lastRefreshingSuccessed
    }
    
    private func refreshToken(for webClient: WebClient) async {
        self.refreshing = true
        
        let refreshToken = accessTokenStorage.getToken(byType: .refresh)
        let providingResult = await self.accessTokenProvider.provideToken(for: webClient,
                                                                          refreshToken: refreshToken)
        
        switch providingResult {
        case let .successed(access, refresh):
            accessTokenStorage.update(accessToken: access,
                                      refreshToken: refresh)
            lastRefreshingSuccessed = true
            
        case let .failed(error):
            #if DEBUG
            print("AccessTokenRefresher error:", error)
            #endif
            lastRefreshingSuccessed = false
        }
        
        notifyWaitingIfNeeded()
        self.refreshing = false
    }
    
    private func waitEndOfRefresh() async {
        return await withCheckedContinuation { continuation in
            waitEndOfRefresh {
                continuation.resume(returning: ())
            }
        }
    }
    
    private func waitEndOfRefresh(onComplete: @escaping () -> Void) {
        refreshingCompletions.append(onComplete)
    }
    
    private func notifyWaitingIfNeeded() {
        while let waiting = refreshingCompletions.first {
            waiting()
            _ = refreshingCompletions.removeFirst()
        }
    }
    
}
