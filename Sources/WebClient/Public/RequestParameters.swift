import Foundation

public struct RequestParameters {
    
    let baseURL: URL
    let method: HTTPMethod
    let body: RequestBody
    let queryItems: [URLQueryItem]
    let additionalHeaders: [RequestHeader]
    let requestProgress: RequestProgress?
    
}
