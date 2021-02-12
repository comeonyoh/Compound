//
//  NetworkQueue.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/12.
//

import Foundation

class NetworkQueue: RequestQueue {

    private var session: URLSession!
    
    private var configuration: URLSessionConfiguration?
    
    public init(configuration sessionConfiguration: URLSessionConfiguration, _ completion: RequestQueue.RequestQueueCompletion?) {
        configuration = sessionConfiguration
        super.init(completion)
    }
    
    override func prepareForInit() {
        session = URLSession(configuration: configuration ?? URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
}

extension NetworkQueue: URLSessionDelegate {
     
}
