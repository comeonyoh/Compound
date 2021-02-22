//
//  Network.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/12.
//

import Foundation

class Network: Request {
    
    //  Target URL's path and sessionTask
    private var path: String!
    
    private var activeURL: URL!
    
    private var sessionTask: URLSessionTask?

    //  Parameters set
    public typealias NetworkTaskHandler = (_ request: Request) -> Void

    public var networkTask: NetworkTaskHandler?

    //  Receiving data
    public private(set) var responseData: Data?
    
    public convenience init(path: String, task: NetworkTaskHandler? = nil) {
        self.init(path: path, task: task, completed: nil)
    }
    
    public init(path: String, task: NetworkTaskHandler? = nil, completed completion: Request.TaskCompletion?) {
        super.init(task: nil, completed: completion)
        self.path = path
        self.networkTask = task
    }
    
    override func cancel() {
        super.cancel()
        sessionTask?.cancel()
    }
    
    override func cancel(_ error: Error) {
        super.cancel(error)
        sessionTask?.cancel()
    }
    
}

extension Network {
    
    override func request(canBegin request: Request) -> Bool {

        guard queue is NetworkQueue else {
            return false
        }

        guard let activeURL = URL(string: path) else {
            return false
        }
        
        self.activeURL = activeURL
        return true
    }

    override func request(didBegan request: Request) {
        
        //  1. Prepare for receving parameters to make appropriate URL.
//        if let task = networkTask {
//            
//        }
        
        //  2. Let's make URLSessionTask with combining the activeURL and parameters from networkTask.
        let networkQueue = queue as! NetworkQueue
        sessionTask = networkQueue.session.dataTask(with: activeURL)

        //  3. Let's resume the task.
        sessionTask?.resume()
    }
}

extension Network {
    
    public func network(receive response: URLResponse, _ completion: @escaping (URLSession.ResponseDisposition) -> Void) {

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            completion(.cancel)
            cancel()
            return
        }
        
        completion(.allow)
    }
    
    public func network(receiveData data: Data) {
        
        if responseData == nil {
            responseData = Data()
        }
        
        responseData?.append(data)
    }
    
    public func network(receiveCompletion error: Error?) {
        
        guard error == nil else {
            cancel(error!)
            return
        }
        
        guard let data = responseData, data.count > 0 else {
            cancel()
            return
        }

        finish()
    }
}
