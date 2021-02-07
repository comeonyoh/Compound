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
    func requestQueue(didCancelled request: Request)
}

public enum RequestQueueError: Error {
    case cancel
}

public class RequestQueue: OperationQueue {
    
    public typealias RequestQueueCompletion = (_ queue: RequestQueue, _ error: RequestQueueError?) -> Void

    private var observation: NSKeyValueObservation!
    
    override init() {
        
        super.init()
        self.maxConcurrentOperationCount = 1
        
        observation = observe(\.progress.fractionCompleted, options: [.old, .new], changeHandler: { [weak self] (queue, info) in
            
            guard let self = self, let fractionCompleted = info.newValue, fractionCompleted == 1.0 else {
                return
            }
            
            self.completion?(self, nil)
        })
    }

    public convenience init(_ completion: RequestQueueCompletion?) {
        self.init()
        self.completion = completion
    }
    
    deinit {
        observation = nil
    }
    
    public var completion: RequestQueueCompletion?
    
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
        operation.request(willAdded: operation)

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
        
        completion?(self, RequestQueueError.cancel)
    }
}

extension RequestQueue: RequestQueueLifeCycle {
    
    func requestQueue(didExecuted request: Request) {
        
    }

    func requestQueue(didFinished request: Request) {
        
    }
 
    func requestQueue(didCancelled request: Request) {
        
    }
    
    private func updateProgress(_ incremental: Bool?) {
        
        if incremental == true {
            self.progress.totalUnitCount += 1
        }
    }
}

