import Foundation

public class WebClient: NSObject {
    
    private var requestsProgress = [Int: RequestProgress]()
    
    private let session: URLSession
    private let baseHeaders: [RequestHeader]
    
    private let authorizer: RequestAuthorizer?
    private let modifier: RequestModifier?
    private let interceptor: RequestInterceptor?
    
    private let authorizationTokenStorage: AuthorizationTokenStorage?
    private let accessTokenRefresher: AccessTokenRefresher?
    
    public init(session: URLSession,
                authorizationMethods: [AuthorizationMethod] = [],
                modifier: RequestModifier? = nil,
                interceptor: RequestInterceptor? = nil,
                accessTokenProvider: AccessTokenProvider? = nil,
                authorizationTokenStorage: AuthorizationTokenStorage? = nil,
                baseHeaders: [RequestHeader] = []) {
        
        self.session = session
        
        if authorizationMethods.isEmpty {
            self.authorizer = nil
        } else {
            self.authorizer = RequestAuthorizer(with: authorizationMethods)
        }
        
        self.modifier = modifier
        self.interceptor = interceptor
        self.baseHeaders = baseHeaders
        self.authorizationTokenStorage = authorizationTokenStorage
        
        if let accessTokenProvider = accessTokenProvider,
           let authorizationTokenStorage = authorizationTokenStorage {
            
            self.accessTokenRefresher = AccessTokenRefresher(withStorage: authorizationTokenStorage,
                                                             andProvider: accessTokenProvider)
        } else {
            self.accessTokenRefresher = nil
        }
        
        super.init()
    }
    
    func register(requestProgress: RequestProgress,
                  for task: URLSessionTask) {
        
        let taskID = task.taskIdentifier
        self.requestsProgress[taskID] = requestProgress
    }
    
    public func request(baseURL: URL,
                        method: HTTPMethod,
                        body: RequestBody = .none,
                        queryItems: [URLQueryItem] = [],
                        additionalHeaders: [RequestHeader] = [],
                        requestProgress: RequestProgress? = nil) async throws -> RequestResponse {
        
        let headers = baseHeaders + additionalHeaders
        
        let request = try prepareRequest(with: baseURL,
                                         queryItems: queryItems,
                                         method: method,
                                         body: body,
                                         headers: headers)
        
        let response = try await response(of: request,
                                          taskType: body.taskType,
                                          requestProgress: requestProgress)
        
        let requestParameters = RequestParameters(baseURL: baseURL,
                                                  method: method,
                                                  body: body,
                                                  queryItems: queryItems,
                                                  additionalHeaders: additionalHeaders,
                                                  requestProgress: requestProgress)
     
        let processedResponse = try await processResponse(response,
                                                          of: request,
                                                          with: requestParameters)
        
        return processedResponse
    }
    
    public func request(with requestParameters: RequestParameters) async throws -> RequestResponse {
        
        return try await request(baseURL: requestParameters.baseURL,
                                 method: requestParameters.method,
                                 body: requestParameters.body,
                                 queryItems: requestParameters.queryItems,
                                 additionalHeaders: requestParameters.additionalHeaders,
                                 requestProgress: requestParameters.requestProgress)
        
    }
    
}

private extension WebClient {
    
    func processResponse(_ response: RequestResponse,
                         of request: URLRequest,
                         with requestParameters: RequestParameters) async throws -> RequestResponse {
        
        guard response.isFailed else {
            return response
        }
        
        guard let interceptor = self.interceptor else {
            return response
        }
            
        let interceptionResult = await interceptor.intercept(request,
                                                             response: response.response,
                                                             error: response.error)
        
        switch interceptionResult {
        case .retryAfterAuthorizationTokenUpdates:
            if let accessTokenRefresher = self.accessTokenRefresher {
                await accessTokenRefresher.waitEndOfRefresh()
                return try await self.request(with: requestParameters)
            }
            
        case let .retryAfterDelay(delayInSeconds):
            let delayInNanoseconds = UInt64(delayInSeconds * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delayInNanoseconds)
            return try await self.request(with: requestParameters)
            
        case .noNeedToRetry:
            break
            
        }
        
        return response
        
    }
    
    func response(of request: URLRequest,
                  taskType: WebClientTaskType,
                  requestProgress: RequestProgress?) async throws -> RequestResponse {
        
        let task = WebClientTask(webClient: self,
                                 session: session,
                                 request: request,
                                 taskType: taskType,
                                 requestProgress: requestProgress)
        
        let response = await task.response()
        
        return response
        
    }
    
    func prepareRequest(with baseURL: URL,
                        queryItems: [URLQueryItem],
                        method: HTTPMethod,
                        body: RequestBody,
                        headers: [RequestHeader]) throws -> URLRequest {
        
        let url = try prepareURL(baseURL: baseURL,
                                 with: queryItems)
        
        let contentTypeHeader: RequestHeader?
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if body.isMultipartForm {
            let boundary = Boundary()
            request.httpBody = body.asBodyData(boundary: boundary)
            
            let contentTypeHeaderValue = "\(ContentType.multipartFormData.rawValue); boundary=\(boundary.forContentTypeHeader())"
            contentTypeHeader = RequestHeader(name: "Content-Type",
                                              value: contentTypeHeaderValue)
        } else {
            request.httpBody = body.asBodyData()
            
            if let contentType = body.contentType {
                contentTypeHeader = RequestHeader(name: "Content-Type",
                                                  value: contentType.rawValue)
            } else {
                contentTypeHeader = nil
            }
        }
        
        if let contentTypeHeader = contentTypeHeader {
            request.addValue(contentTypeHeader.value,
                             forHTTPHeaderField: contentTypeHeader.name)
        }
        
        headers.forEach {
            request.addValue($0.value,
                             forHTTPHeaderField: $0.name)
        }
        
        modifier?.modify(&request)
        
        if let authorizationTokenStorage = self.authorizationTokenStorage {
            authorizer?.authorizeRequest(&request,
                                         usingStorage: authorizationTokenStorage)
        }
        
        return request
        
    }
    
    func prepareURL(baseURL: URL,
                    with queryItems: [URLQueryItem]) throws -> URL {
        
        guard !queryItems.isEmpty else {
            return baseURL
        }
        
        guard var components = URLComponents(url: baseURL,
                                             resolvingAgainstBaseURL: true) else {
            throw WebClientError.invalidURL
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw WebClientError.invalidURL
        }
        
        return url
    }
    
}

extension WebClient: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64) {
        
        let taskID = task.taskIdentifier
        
        guard let task = self.requestsProgress[taskID] else {
            return
        }
        
        task.updateWith(totalBytesSent: totalBytesSent,
                        totalBytesExpectedToSend: totalBytesExpectedToSend)
        
        if totalBytesSent == totalBytesExpectedToSend {
            self.requestsProgress.removeValue(forKey: taskID)
        }
        
    }
    
}
