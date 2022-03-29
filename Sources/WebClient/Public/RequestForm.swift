import Foundation

public class RequestForm {
    
    private var values = [RequestFormValue]()
    
}

extension RequestForm {
    
    public func append(_ value: RequestFormValue) {
        self.values.append(value)
    }
    
    public func appending(_ value: RequestFormValue) -> RequestForm {
        self.values.append(value)
        return self
    }
    
    func asMultipartFormBodyData(boundary: Boundary) -> Data? {
        let valuesMultipartData = values.compactMap { $0.multipartData }
        
        guard !valuesMultipartData.isEmpty else {
            return nil
        }
        
        let dataBuilder = DataBuilder()
        
        valuesMultipartData.forEach {
            dataBuilder.append(string: boundary.forParameter())
            dataBuilder.append(data: $0)
        }
        
        dataBuilder.append(string: boundary.forClosing())
        
        return dataBuilder.data
    }
    
    func asFormUrlencodedBodyData() -> Data? {
        let compatibleValues = values.filter { $0.compatibleToFormURLEncoded }
        
        let pairs = compatibleValues.compactMap { value -> String? in
            if let stringValue = value.valueType.stringValue {
                return "\(value.name)=\(stringValue)"
            }
            return nil
        }
        
        let body = pairs.joined(separator: "&")
        let bodyData = body.data(using: .utf8)
        
        return bodyData
    }
    
}
