//
//  Requests.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/02.
//

import Foundation

public class Requests: Request, ExpressibleByArrayLiteral {
    
    public private(set) var requests: [Request]!
    
    private var cancelledRequests = [Request]()

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
        
        if cancelledRequests.count > 0 {
            cancel()
        }
        else {
            super.start()
            finish()
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
    
    override func request(didBegin request: Request) {
        
    }
    
    override func request(didFinished request: Request) {
    }
    
    override func request(didCancelled request: Request) {
        cancelledRequests.append(request)
    }
}
