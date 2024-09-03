import Foundation

final class AccessTokenRefresher {
    
    typealias Completion = () -> Void
    
    private let accessTokenStorage: AuthorizationTokenStorage
    private let accessTokenProvider: AccessTokenProvider
    
    private var refreshingLock = NSLock()
    private var refreshing = false
    private var refreshingContinuations = [CheckedContinuation<Bool, Never>]()
    
    public init(withStorage accessTokenStorage: AuthorizationTokenStorage,
                andProvider accessTokenProvider: AccessTokenProvider) {
        
        self.accessTokenStorage = accessTokenStorage
        self.accessTokenProvider = accessTokenProvider
    }
    
    func refreshToken(using webClient: WebClient) async -> Bool {
        let refreshTask = refreshingLock.withLock {
            if refreshing {
                Task {
                    await withCheckedContinuation { refreshContinuation in
                        refreshingContinuations.append(refreshContinuation)
                    }
                }
            } else {
                Task {
                    await refreshTokenWithContinuationResuming(using: webClient)
                }
            }
        }
        
        do {
            return try await refreshTask.value
        } catch {
            return false
        }
    }
    
}

private extension AccessTokenRefresher {
    
    private func refreshTokenWithContinuationResuming(using webClient: WebClient) async -> Bool {
        refreshingLock.withLock { refreshing = true }
        
        let refreshToken = accessTokenStorage.getToken(byType: .refresh)
        let providingResult = await self.accessTokenProvider.provideToken(for: webClient,
                                                    refreshToken: refreshToken)
        
        let successed: Bool
        switch providingResult {
        case let .successed(access, refresh):
            accessTokenStorage.update(accessToken: access,
                                      refreshToken: refresh)
            #if DEBUG
            print("AccessTokenRefresher updates token pair")
            #endif
            successed = true
            
        case let .failed(error):
            #if DEBUG
            print("AccessTokenRefresher error:", error)
            #endif
            successed = false
        }
        
        refreshingLock.withLock {
            for refreshContinuation in refreshingContinuations {
                refreshContinuation.resume(returning: successed)
            }
            refreshingContinuations = []
            refreshing = false
        }
        
        return successed
    }
    
}
