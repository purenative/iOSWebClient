import Foundation

public enum RequestBody {
    
    case none
    case json(json: RequestJSON)
    case multipart(form: RequestForm)
    case urlencoded(form: RequestForm)
    
}

extension RequestBody {
    
    var contentType: ContentType? {
        switch self {
        case .json:
            return .applicationJson
            
        case .multipart:
            return .multipartFormData
            
        case .urlencoded:
            return .applicationFormUrlencoded
            
        default:
            return nil
        }
    }
    
    var isMultipartForm: Bool {
        switch self {
        case .multipart:
            return true
            
        default:
            return false
        }
    }
    
    func asBodyData(boundary: Boundary? = nil) -> Data? {
        switch self {
        case .none:
            return nil
            
        case let .json(body):
            return body.data
            
        case let .multipart(form):
            guard let boundary = boundary else {
                return nil
            }
            return form.asMultipartFormBodyData(boundary: boundary)
            
        case let .urlencoded(form):
            return form.asFormUrlencodedBodyData()
        }
    }
    
    var taskType: WebClientTaskType {
        switch self {
        case .none, .json:
            return .dataTask
            
        case .multipart, .urlencoded:
            return .uploadTask
        }
    }
    
}
