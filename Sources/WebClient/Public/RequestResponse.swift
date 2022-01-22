import Foundation

public struct RequestResponse {
    
    let taskResponse: TaskResponse?
    let response: HTTPURLResponse?
    let error: Error?
    
    init(taskResponse: TaskResponse?,
         response: URLResponse?,
         error: Error?) {
        
        self.taskResponse = taskResponse
        self.response = response as? HTTPURLResponse
        self.error = error
    }
    
    public var statusCode: Int? {
        response?.statusCode
    }
    
    public var isSuccessed: Bool {
        guard let statusCode = statusCode else {
            return false
        }

        return 200..<300 ~= statusCode
    }
    
    public var isFailed: Bool {
        error != nil || !isSuccessed
    }
    
    public var fileURL: URL? {
        switch self.taskResponse {
        case let .fileURL(url):
            return url
            
        default:
            return nil
        }
    }
    
    public var data: Data? {
        switch self.taskResponse {
        case let .data(data):
            return data
            
        default:
            return nil
        }
    }
    
    public func asDecodable<D: Decodable>(jsonDecoder: JSONDecoder = .init()) throws -> D {
        guard let data = data else {
            throw WebClientError.dataIsEmpty
        }
        
        return try jsonDecoder.decode(D.self, from: data)
    }
    
}
