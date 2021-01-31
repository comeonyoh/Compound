//
//  Request.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import Foundation

protocol RequestLifeCycle {

    func request(canBegin request: Request) -> Bool
    func request(didBegin request: Request)
    
    func request(canFinished request: Request) -> Bool
    func request(didFinished request: Request)
    
    func request(didCancelled request: Request)
}

public class Request: Operation {
    
    public typealias TaskHandler = (_ request: Request) -> Void
    
    private enum State: String {
        
        case ready
        case finished
        case executing
        
        var keyPath: String {
            return "is\(rawValue.capitalized)"
        }
    }
    
    public override init() {
        super.init()
    }
    
    private var state: State = .ready {
        
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
            
            if state == .finished && isCancelled == false {
                self.request(didFinished: self)
                queue?.requestQueue(didFinished: self)
            }
        }
    }
    
    public var task: TaskHandler?
    
    public weak var queue: RequestQueue?
    
    public override func start() {

        guard request(canBegin: self) else {
            cancel()
            return
        }
        
        request(didBegin: self)
        super.start()
    }
    
    public override func cancel() {
        
        super.cancel()
        self.state = .finished
        request(didCancelled: self)
        queue?.requestQueue(didCancelled: self)
    }
    
    public func finish() {
        state = .finished
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

    }
    
    func request(canFinished request: Request) -> Bool {
        true
    }
    
    func request(didFinished request: Request) {

    }
    
    func request(didCancelled request: Request) {

    }
}

