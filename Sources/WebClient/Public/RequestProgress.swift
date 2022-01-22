import Combine

public class RequestProgress: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published
    public var totalBytesSent: Int64 = 0
    
    @Published
    public var totalBytesExpectedToSend: Int64 = 0
    
    @Published
    public var progress: Double = 0
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func updateWith(totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        
        self.totalBytesSent = totalBytesSent
        self.totalBytesExpectedToSend = totalBytesExpectedToSend
        self.progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
    }
    
    public func subscribe(onProgressChanged: @escaping (Double) -> Void) {
         $progress.removeDuplicates()
            .sink {
                onProgressChanged($0)
             }
             .store(in: &cancellables)
    }
    
}
