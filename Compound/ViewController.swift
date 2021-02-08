//
//  ViewController.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import UIKit

class ViewController: UIViewController {

    var queue: RequestQueue!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        queue = RequestQueue { (queue, error) in
            print("Request completed = \(error)")
        }
        
        let request1 = Request {
            print("request1")
            $0.cancel(RequestError.sampleError)
        }
        let request2 = Request {
            print("request2")
            $0.finish()
        }
                
        request1.name = "REQ1"
        request2.name = "REQ2"
        
        let requests: Requests = [request1, request2]
        
        requests.task = { _ in
            print("Requests called")
        }
        
        requests.cancelValidator = {
            _, _ in
            
            return false
        }
        
        queue.addOperation(requests)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        print(queue.operations)
    }
}

