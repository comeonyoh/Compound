//
//  Requests.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/02.
//

import Foundation

public class Requests: Request, ExpressibleByArrayLiteral {
    
    public private(set) var requests: [Request]!
    
    private var dictionary = [String: Any]()
    
    public func add(_ request: Request) {
        requests.append(request)
        request.parent = self
    }
    
    override init() {
        super.init()
        self.requests = [Request]()
    }
    
    public required init(arrayLiteral elements: Request...) {
        super.init()
        self.requests = [Request]()
        
        for element in elements {
            add(element)
        }
    }
    
    public override func start() {
        
        super.start()
        deferredCancel ? cancel() : finish()
    }
    
    subscript(key: String) -> Any? {
        
        set {
            dictionary[key] = newValue
        }
        get {
            dictionary[key]
        }
    }
}

extension Requests: Collection {
    
    public func index(after i: Int) -> Int {
        requests.index(after: i)
    }
    
    public subscript(position: Int) -> Request {
        requests[position]
    }
    
    public var startIndex: Int {
        requests.startIndex
    }
    
    public var endIndex: Int {
        requests.endIndex
    }
    
    public var count: Int {
        requests.count
    }
}

extension Requests {
    
    override func request(willBegin request: Request) {
    }
    
    override func request(didFinished request: Request) {
    }
    
    override func request(didCancelled request: Request, reason error: Error) {

        guard let index = self.firstIndex(of: request) else {
            return
        }
        
        requests[index+1..<count].forEach {
            $0.deferredCancel = true
        }
        
        self.deferredCancel = true
    }
}
