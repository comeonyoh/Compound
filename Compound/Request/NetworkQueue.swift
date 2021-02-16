//
//  NetworkQueue.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/12.
//

import Foundation

class NetworkQueue: RequestQueue {

    public private(set) var session: URLSession!
    
    private var configuration: URLSessionConfiguration?
    
    public init(configuration sessionConfiguration: URLSessionConfiguration, _ completion: RequestQueue.RequestQueueCompletion?) {
        configuration = sessionConfiguration
        super.init(completion)
    }
    
    override func prepareForInit() {
        session = URLSession(configuration: configuration ?? URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
}

extension NetworkQueue: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceive response")
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceive data")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("didCompleteWithError")
    }
}
