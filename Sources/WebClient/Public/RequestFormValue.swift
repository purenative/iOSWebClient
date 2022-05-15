import UIKit

public class RequestFormValue {
    
    let valueType: RequestFormValueType
    let name: String
    
    init(valueType: RequestFormValueType,
         name: String) {
        
        self.valueType = valueType
        self.name = name
    }
    
}

extension RequestFormValue {
    
    var compatibleToFormURLEncoded: Bool {
        switch self.valueType {
        case .image, .file:
            return false
            
        default:
            return true
        }
    }
    
    var multipartData: Data? {
        let endLine = "\r\n"

        let dataBuilder = DataBuilder()
        
        dataBuilder.append(string: "Content-Disposition: form-data; name=\"\(self.name)\"")
        
        switch self.valueType {
        case .bool, .int, .float, .double, .string:
            dataBuilder.append(string: endLine + endLine)
            dataBuilder.append(string: self.valueType.stringValue)
            dataBuilder.append(string: endLine)
            
        case let .json(json):
            dataBuilder.append(string: endLine)
            dataBuilder.append(string: "Content-Type: \(ContentType.applicationJson.rawValue)\(endLine + endLine)")
            dataBuilder.append(string: json.stringValue)
            dataBuilder.append(string: endLine)

        case let .file(url):
            if let fileData = try? Data(contentsOf: url) {
                let fileName = url.lastPathComponent

                dataBuilder.append(string: "; filename=\"\(fileName)\"\(endLine)")
                dataBuilder.append(string: "Content-Type: \(ContentType.applicationOctetStream.rawValue)\(endLine + endLine)")
                dataBuilder.append(data: fileData)
                dataBuilder.append(string: endLine)
            } else {
                return nil
            }
            
        case let .image(image, fileName):
            if let pngImageData = image.pngData() {
                dataBuilder.append(string: "; filename=\"\(fileName)\"\(endLine)")
                dataBuilder.append(string: "Content-Type: \(ContentType.imagePng.rawValue)\(endLine + endLine)")
                dataBuilder.append(data: pngImageData)
                dataBuilder.append(string: endLine)
            } else {
                return nil
            }
        }
        
        return dataBuilder.data
    }
    
}

public extension RequestFormValue {
    
    static func bool(_ value: Bool,
                     named: String) -> RequestFormValue {
        
        .init(valueType: .bool(value),
              name: named)
    }
    
    static func int(_ value: Int,
                    named: String) -> RequestFormValue {
        
        .init(valueType: .int(value),
              name: named)
    }
    
    static func float(_ value: Float,
                      named: String) -> RequestFormValue {
        
        .init(valueType: .float(value),
              name: named)
    }
    
    static func double(_ value: Double,
                       named: String) -> RequestFormValue {
        
        .init(valueType: .double(value),
              name: named)
    }
    
    static func string(_ value: String,
                       named: String) -> RequestFormValue {
        
        .init(valueType: .string(value),
              name: named)
    }
    
    static func image(_ image: UIImage,
                      fileName: String,
                      named: String) -> RequestFormValue {
        
        .init(valueType: .image(image, fileName: fileName),
              name: named)
    }
    
    static func file(_ fileURL: URL,
                     named: String) -> RequestFormValue {
        
        .init(valueType: .file(fileURL),
              name: named)
    }
    
}
