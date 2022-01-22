import Foundation

final class DataBuilder {
    
    var data = Data()
    
    func append(data: Data?) {
        guard let data = data else {
            return
        }
        
        self.data += data
    }
    
    func append(string: String?,
                encoding: String.Encoding = .utf8) {
        
        let data = string?.data(using: encoding)
        self.append(data: data)
    }
    
    func clear() {
        self.data = Data()
    }
    
}
