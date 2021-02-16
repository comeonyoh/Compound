//
//  Request.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import Foundation

@objc
protocol RequestLifeCycle {

    func request(canBegin request: Request) -> Bool
    func request(willBegin request: Request)
    func request(didBegan request: Request)

    func request(didFinished request: Request)
    func request(didCancelled request: Request, reason error: Error)
}

public class Request: Operation {
    
    public typealias TaskHandler = (_ request: Request) -> Void
    public typealias TaskCompletion = (_ request: Request, _ error: Error?) -> Void

    //  Handling for duplicated insertion on OperationQueue. It is useful when working in Requests circumstances.
    public internal(set) var isAddedOnQueue: Bool = false
    
    public weak var parent: Requests?
    
    private enum State: String {
        
        case ready
        case finished
        case executing
        
        var keyPath: String {
            return "is\(rawValue.capitalized)"
        }
    }
    
    private var state: State = .ready {
        
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    public var task: TaskHandler?
    public var customCompletion: TaskCompletion?

    public override init() {
        super.init()
    }
    
    public convenience init(task: TaskHandler? = nil) {
        self.init(task: task, completed: nil)
    }
    
    public init(task: TaskHandler? = nil, completed completion: TaskCompletion?) {
        super.init()
        self.task = task
        self.customCompletion = completion
    }

    public weak var queue: RequestQueue?
    
    public override func start() {

        guard request(canBegin: self) else {
            cancel()
            return
        }

        guard isCancelled == false else {
            return
        }
        
        request(willBegin: self)
        super.start()
    }
    
    internal var deferredCancel: Bool = false
    
    public override func cancel() {
        cancel(RequestError.cancel)
    }
    
    public func cancel(_ error: Error) {
        
        super.cancel()
        
        request(didCancelled: self, reason: error)
        queue?.requestQueue(didCancelled: self, reason: error)
        
        task = nil
        state = .finished

        customCompletion?(self, RequestError.cancel)
        customCompletion = nil
    }
    
    public func finish() {

        request(didFinished: self)
        queue?.requestQueue(didFinished: self)

        state = .finished

        customCompletion?(self, nil)
        customCompletion = nil
    }
    
    public override func main() {
        
        state = .executing
        
        if deferredCancel == false {
            
            queue?.requestQueue(didExecuted: self)
            request(didBegan: self)
        }
        else {
            cancel(RequestError.skip)
        }
    }
    
    public override var isReady: Bool {
        super.isReady && state == .ready
    }
    
    public override var isExecuting: Bool {
        state == .executing
    }
    
    public override var isFinished: Bool {
        state == .finished
    }
}

extension Request: RequestLifeCycle {
    
    func request(canBegin request: Request) -> Bool {
        true
    }
    
    func request(didBegan request: Request) {
        task?(self)
        parent?.request(didBegan: request)
    }
    
    func request(willBegin request: Request) {
        print("Request \(String(describing: request.name)) begin")
        parent?.request(willBegin: request)
    }
    
    func request(didFinished request: Request) {
        print("Request \(String(describing: request.name)) finished")
        parent?.request(didFinished: request)
    }
    
    func request(didCancelled request: Request, reason error: Error) {
        print("Request \(String(describing: request.name)) cancelled")
        parent?.request(didCancelled: request, reason: error)
    }
}

