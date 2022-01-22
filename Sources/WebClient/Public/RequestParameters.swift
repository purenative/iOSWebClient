import Foundation

public struct RequestParameters {
    
    let baseURL: URL
    let method: HTTPMethod
    let body: RequestBody
    let queryItems: [URLQueryItem]
    let additionalHeaders: [RequestHeader]
    let requestProgress: RequestProgress?
    
    public init(baseURL: URL,
                method: HTTPMethod = .get,
                body: RequestBody = .none,
                queryItems: [URLQueryItem] = [],
                additionalHeaders: [RequestHeader] = [],
                requestProgress: RequestProgress? = nil) {
        
        self.baseURL = baseURL
        self.method = method
        self.body = body
        self.queryItems = queryItems
        self.additionalHeaders = additionalHeaders
        self.requestProgress = requestProgress
        
    }
    
}
