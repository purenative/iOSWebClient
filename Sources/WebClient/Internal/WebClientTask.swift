import Foundation

class WebClientTask {
    
    typealias TaskCompletion = (TaskResponse?, URLResponse?, Error?)
    typealias TaskCompletionHandler = (TaskCompletion) -> Void
    
    private let request: URLRequest
    private let taskType: WebClientTaskType
    
    private weak var session: URLSession?
    private weak var webClient: WebClient?
    private weak var requestProgress: RequestProgress?
    
    private var task: URLSessionTask?
    
    init(webClient: WebClient?,
         session: URLSession?,
         request: URLRequest,
         taskType: WebClientTaskType,
         requestProgress: RequestProgress?) {
            
        self.webClient = webClient
        self.session = session
        
        self.request = request
        self.taskType = taskType
        
        self.requestProgress = requestProgress
    }
    
    func response() async -> RequestResponse {
        await withTaskCancellationHandler(operation: {
            await getResponse()
        }, onCancel: { [weak self] in
            self?.cancel()
        })
    }
    
    func cancel() {
        task?.cancel()
    }
    
}

private extension WebClientTask {
    
    private func getResponse() async -> RequestResponse {
        await withCheckedContinuation { continuation in
            getResponse { completion in
                let response = RequestResponse(taskResponse: completion.0,
                                               response: completion.1,
                                               error: completion.2)
                continuation.resume(returning: response)
            }
        }
    }
    
    private func getResponse(completionHandler: @escaping TaskCompletionHandler) {
        guard let webClient = webClient,
              let session = session else {
            let completion: TaskCompletion = (nil, nil, WebClientError.taskCancelled)
            completionHandler(completion)
            return
        }

        switch taskType {
        case .dataTask:
            task = session.dataTask(with: request) { data, response, error in
                let completion: TaskCompletion = (.data(data), response, error)
                completionHandler(completion)
            }
            
        case .uploadTask:
            task = session.uploadTask(with: request, from: request.httpBody) { data, response, error in
                let completion: TaskCompletion = (.data(data), response, error)
                completionHandler(completion)
            }
            
        case .downloadTask:
            task = session.downloadTask(with: request) { url, response, error in
                let completion: TaskCompletion = (.fileURL(url), response, error)
                completionHandler(completion)
            }
        }
        
        guard let task = task else {
            return
        }
        
//        task.delegate = webClient FIXME: What ???
        
        if let requestProgress = requestProgress {
            webClient.register(requestProgress: requestProgress,
                               for: task)
        }
        
        task.resume()
    }
    
}
