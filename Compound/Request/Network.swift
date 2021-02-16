//
//  Network.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/12.
//

import Foundation

class Network: Request {
    
    private var path: String!
    
    private var activeURL: URL!
    
    internal var sessionTask: URLSessionTask?

    public convenience init(path: String, task: Request.TaskHandler? = nil) {
        self.init(path: path, task: task, completed: nil)
    }
    
    public init(path: String, task: Request.TaskHandler? = nil, completed completion: Request.TaskCompletion?) {

        super.init(task: task, completed: completion)
        self.path = path
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
        
        //  1. Create network task
        let networkQueue = queue as! NetworkQueue
        sessionTask = networkQueue.session.dataTask(with: activeURL)
        
        //  2. Ask first to task block whether it goes or not.
        if let task = task {
            
        }
        //  3. Just go when there is no task block.
        else {
            sessionTask?.resume()
        }
    }
}
