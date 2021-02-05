//
//  Request.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import Foundation

@objc
protocol RequestLifeCycle {

    @objc
    func request(canBegin request: Request) -> Bool
    func request(didBegin request: Request)
    
    func request(canFinished request: Request) -> Bool
    func request(didFinished request: Request)
    
    func request(didCancelled request: Request)
}

public class Request: Operation {
    
    public typealias TaskHandler = (_ request: Request) -> Void
    public typealias TaskCompletion = (_ request: Request, _ error: Error?) -> Void

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
    
    public init(_ task: TaskHandler?) {
        self.task = task
    }
    
    public init(_ task: TaskHandler?, completed completion: TaskCompletion?) {
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
        
        request(didBegin: self)
        super.start()
    }
    
    public override func cancel() {
        
        super.cancel()
        
        state = .finished

        task = nil
        request(didCancelled: self)
        queue?.requestQueue(didCancelled: self)
    }
    
    public func finish() {

        state = .finished

        customCompletion?(self, nil)
        customCompletion = nil
        
        request(didFinished: self)
        queue?.requestQueue(didFinished: self)
    }
    
    public override func main() {
        
        state = .executing
        queue?.requestQueue(didExecuted: self)
        task?(self)
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
    
    func request(didBegin request: Request) {
        print("Request \(String(describing: request.name)) begin")
        parent?.request(didBegin: request)
    }
    
    func request(canFinished request: Request) -> Bool {
        true
    }
    
    func request(didFinished request: Request) {
        print("Request \(request.name) finished")
        parent?.request(didFinished: request)
    }
    
    func request(didCancelled request: Request) {

    }
}

