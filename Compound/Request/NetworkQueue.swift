//
//  NetworkQueue.swift
//  Compound
//
//  Created by JungSu Kim on 2021/02/12.
//

import Foundation

class NetworkQueue: RequestQueue {

    private var activeNetwork: Network?
    public private(set) var session: URLSession!
    
    private var configuration: URLSessionConfiguration?
    
    public init(configuration sessionConfiguration: URLSessionConfiguration, _ completion: RequestQueue.RequestQueueCompletion?) {
        configuration = sessionConfiguration
        super.init(completion)
    }
    
    override func prepareForInit() {
        super.prepareForInit()
        session = URLSession(configuration: configuration ?? URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
}

extension NetworkQueue {
    
    override func requestQueue(didBegan request: Request) {
        
        if request is Network {
            activeNetwork = request as? Network
        }
    }
    
    override func requestQueue(didFinished request: Request) {
        super.requestQueue(didFinished: request)
        activeNetwork = nil
    }
    
    override func requestQueue(didCancelled request: Request, reason error: Error) {
        super.requestQueue(didCancelled: request, reason: error)
        activeNetwork = nil
    }
}

extension NetworkQueue: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.activeNetwork?.network(receive: response, completionHandler)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.activeNetwork?.network(receiveData: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.activeNetwork?.network(receiveCompletion: error)
    }
}
