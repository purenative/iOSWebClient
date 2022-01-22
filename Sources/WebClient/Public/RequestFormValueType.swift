import UIKit

enum RequestFormValueType {
    
    case bool(Bool)
    case int(Int)
    case float(Float)
    case double(Double)
    case string(String)
    case image(UIImage, fileName: String)
    case file(URL)
    case json(RequestJSON)
    
}

extension RequestFormValueType {
    
    var stringValue: String? {
        switch self {
        case let .bool(bool):
            return "\(bool)"
            
        case let .int(int):
            return "\(int)"
            
        case let .float(float):
            return "\(float)"
            
        case let .double(double):
            return "\(double)"
            
        case let .string(string):
            return string
            
        case let .json(json):
            return json.stringValue
            
        default:
            return nil
        }
    }
    
}
