//
//  RequestQueue.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import Foundation

protocol RequestQueueLifeCycle {

    func requestQueue(didExecuted request: Request)
    func requestQueue(didFinished request: Request)
    func requestQueue(didCancelled request: Request, reason error: Error)
}

public enum RequestError: Error {
    case unknown
    case cancel
    case skip
    case sampleError
}

public class RequestQueue: OperationQueue {
    
    public typealias RequestQueueCompletion = (_ queue: RequestQueue, _ error: Error?) -> Void

    private var error: Error?

    private var observation: NSKeyValueObservation!
    
    public var completion: RequestQueueCompletion?

    override init() {
        
        super.init()
        self.maxConcurrentOperationCount = 1
        
        observation = observe(\.progress.fractionCompleted, options: [.old, .new], changeHandler: { [weak self] (queue, info) in
            
            guard let self = self, let fractionCompleted = info.newValue, fractionCompleted == 1.0 else {
                return
            }
            
            self.completion?(self, self.error)
        })
    }

    public convenience init(_ completion: RequestQueueCompletion?) {
        self.init()
        self.completion = completion
    }
    
    deinit {
        observation = nil
    }
    
    public override func addOperation(_ op: Operation) {
        
        guard let operation = op as? Request else {
            return
        }
        
        guard operation.isAddedOnQueue == false else {
            return
        }
        
        if let requests = operation as? Requests {
            
            for request in requests.requests {
                addOperation(request)
            }
        }
        
        operation.queue = self
        updateProgress(true)
        operation.isAddedOnQueue = true

        super.addOperation(operation)
    }
    
    public override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        
        var operations = ops.filter {
            $0 is Request ? true : false
        }
        
        operations.forEach {
            
            if let requests = $0 as? Requests {
                operations.insert(contentsOf: requests.requests, at: operations.firstIndex(of: requests)!)
            }
        }
        
        for operation in operations {
            addOperation(operation)
        }
    }
    
    public override func addOperation(_ block: @escaping () -> Void) {
        assertionFailure("NOT SUPPORTED YET")
    }
    
    public override func addBarrierBlock(_ barrier: @escaping () -> Void) {
        assertionFailure("NOT SUPPORTED YET")
    }
    
    public override func cancelAllOperations() {
        
        super.cancelAllOperations()
        
        guard self.progress.fractionCompleted != 1.0 else {
            return
        }
        
        completion?(self, RequestError.cancel)
    }
}

extension RequestQueue: RequestQueueLifeCycle {
    
    func requestQueue(didExecuted request: Request) {
        
    }

    func requestQueue(didFinished request: Request) {
        self.error = nil
    }
 
    func requestQueue(didCancelled request: Request, reason error: Error) {
        
        if self.error == nil {
            self.error = error
        }
    }

    private func updateProgress(_ incremental: Bool?) {
        
        if incremental == true {
            self.progress.totalUnitCount += 1
        }
    }
}

