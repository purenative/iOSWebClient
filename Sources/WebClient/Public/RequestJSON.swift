import Foundation

public struct RequestJSON {
    let data: Data?
    
    public init<E: Encodable>(encodable: E) {
        let jsonEncoder = JSONEncoder()
        self.data = try? jsonEncoder.encode(encodable)
    }
    
    public init(jsonObject: Any,
                prettyPrinted: Bool = true) {
        
        var options: JSONSerialization.WritingOptions = []
        
        if prettyPrinted {
            options = [options, .prettyPrinted]
        }
        
        self.data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                options: options)
    }
}

extension RequestJSON {
    
    var stringValue: String {
        let invalidString = ""
        
        guard let data = data else {
            return invalidString
        }
        
        let string = String(data: data,
                            encoding: .utf8)
        
        return string ?? invalidString
    }
    
}
