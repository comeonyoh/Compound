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

public class RequestQueue: OperationQueue {
    
    public typealias RequestQueueCompletion = (_ queue: RequestQueue, _ error: Error?) -> Void

    var observation: NSKeyValueObservation!
    
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
    
    public var completion: RequestQueueCompletion?
    
    public override func addOperation(_ op: Operation) {
        
        guard let operation = op as? Request else {
            return
        }
        
        operation.queue = self
        updateProgress(true)

        super.addOperation(operation)
    }
    
    public override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        
        let operations = ops.filter {
            $0 is Request ? true : false
        }
        
        super.addOperations(operations, waitUntilFinished: wait)
    }
    
    public override func addOperation(_ block: @escaping () -> Void) {
        assertionFailure("NOT SUPPORTED YET")
    }
    
    public override func addBarrierBlock(_ barrier: @escaping () -> Void) {
        assertionFailure("NOT SUPPORTED YET")
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
