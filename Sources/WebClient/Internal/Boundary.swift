struct Boundary {
    
    private let endLine = "\r\n"
    
    let base: String
    
    init() {
        let value = UInt32.random(in: UInt32.min...UInt32.max)
        self.base = String(format: "%08x", value)
    }
    
    func forContentTypeHeader() -> String {
        "--\(base)\(endLine)"
    }
    
    func forParameter() -> String {
        "\(endLine)--\(base)\(endLine)"
    }
    
    func forClosing() -> String {
        "\(endLine)--\(base)--\(endLine)"
    }
    
}
