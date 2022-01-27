actor AccessTokenRefresher {
    
    typealias Completion = () -> Void
    
    private let accessTokenStorage: AuthorizationTokenStorage
    private let accessTokenProvider: AccessTokenProvider
    
    private var refreshingCompletions = [Completion]()
    
    private(set) var refreshing: Bool = false {
        didSet {
            notifyWaitingIfNeeded()
        }
    }
    
    public init(withStorage accessTokenStorage: AuthorizationTokenStorage,
                andProvider accessTokenProvider: AccessTokenProvider) {
        
        self.accessTokenStorage = accessTokenStorage
        self.accessTokenProvider = accessTokenProvider
    }
    
    func refreshToken(for webClient: WebClient) async -> Bool {
        self.refreshing = true
        
        let refreshToken = accessTokenStorage.getToken(byType: .refresh)
        let providingResult = await self.accessTokenProvider.provideToken(for: webClient,
                                                                          refreshToken: refreshToken)

        let success: Bool
        
        switch providingResult {
        case let .successed(access, refresh):
            accessTokenStorage.update(accessToken: access,
                                      refreshToken: refresh)
            success = true
            
        case let .failed(error):
            #if DEBUG
            print("AccessTokenRefresher error:", error)
            #endif
            success = false
        }
        
        self.refreshing = false
        return success
    }
    
    func waitEndOfRefresh() async {
        if refreshing {
            return await withCheckedContinuation { continuation in
                continuation.resume(returning: ())
            }
        }
    }
    
    private func waitEndOfRefresh(onComplete: @escaping () -> Void) {
        refreshingCompletions.append(onComplete)
    }
    
    private func notifyWaitingIfNeeded() {
        guard !refreshing else {
            return
        }
        
        while let waiting = refreshingCompletions.first {
            waiting()
            _ = refreshingCompletions.removeFirst()
        }
    }
    
}
