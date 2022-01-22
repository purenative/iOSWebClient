public enum RequestInterceptorResult {
    
    case retryAfterAuthorizationTokenUpdates
    case retryAfterDelay(delay: Double)
    case noNeedToRetry
    
}
