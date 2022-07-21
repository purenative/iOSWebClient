import Foundation

public struct RequestParameters {
    
    public let baseURL: URL
    public let method: HTTPMethod
    public let body: RequestBody
    public let queryItems: [URLQueryItem]
    public let additionalHeaders: [RequestHeader]
    public let requestProgress: RequestProgress?
    
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
