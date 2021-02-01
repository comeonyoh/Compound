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
            print("Request completed")
        }
        
        let request1 = Request {
            print("request 1")
            sleep(2)
            $0.cancel()
        }

        let request2 = Request()
        let request3 = Request {
            print("request 3")
            $0.finish()
        } completed: { (request, error) in
            print("request 3 finished")
        }

        request2.task = {
            print("request 2")
            $0.finish()
        }
        
        request3.queuePriority = .veryHigh

        print("req1 = \(request1)")
        print("req2 = \(request2)")
        print("req3 = \(request3)")

        queue.addOperations([request1, request2, request3], waitUntilFinished: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        print(queue.operations)
    }
}

