//
//  Requests.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/02.
//

import Foundation

class Requests: Request, ExpressibleByArrayLiteral {
    
    private var requests: [Request]!
    
    public func add(_ request: Request) {
        requests.append(request)
    }
    
    override init() {
        super.init()
        self.requests = [Request]()
    }
    
    required init(arrayLiteral elements: Request...) {
        super.init()
        self.requests = elements
    }
    
}

extension Requests: Collection {
    
    func index(after i: Int) -> Int {
        requests.index(after: i)
    }
    
    subscript(position: Int) -> Request {
        requests[position]
    }
    
    var startIndex: Int {
        requests.startIndex
    }
    
    var endIndex: Int {
        requests.endIndex
    }
}

extension Requests {
    
    override func request(didBegin request: Request) {
        
    }
}
