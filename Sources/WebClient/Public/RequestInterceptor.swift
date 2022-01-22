import Foundation

public protocol RequestInterceptor {
    
    func intercept(_ request: URLRequest,
                   response: URLResponse?,
                   error: Error?) async -> RequestInterceptorResult
    
}
