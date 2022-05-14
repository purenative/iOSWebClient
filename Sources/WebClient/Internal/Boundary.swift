struct Boundary {
    
    private let newLine = "\n"
    
    let base: String
    
    init() {
        let value = UInt32.random(in: UInt32.min...UInt32.max)
        self.base = String(format: "%08x", value)
    }
    
    func forContentTypeHeader() -> String {
        "--\(base)"
    }
    
    func forParameter() -> String {
        "--\(base)\(newLine)"
    }
    
    func forClosing() -> String {
        "--\(base)--\(newLine)"
    }
    
}
