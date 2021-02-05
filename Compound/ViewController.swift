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
        
        var number = 0
        queue = RequestQueue { (queue, error) in
            print("Request completed = \(number)")
        }
        
        let request1 = Request {
            print("request1")
            number += 5
            $0.finish()
        }
        
        let request2 = Request {
            print("request2")
            number *= 10
            $0.finish()
        }
        
        request1.name = "NAME1"
        request2.name = "NAME2"
        
        let requests: Requests = [request1, request2]

        let request3 = Request {
            print("request3")
            $0.finish()
        }
        request3.name = "NAME3"

        queue.addOperations([requests, request3], waitUntilFinished: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        print(queue.operations)
    }
}

