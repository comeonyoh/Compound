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
        
        queue = RequestQueue()
        
        let request1 = Request()
        let request2 = Request()
        let request3 = Request()

        request1.task = {
            $0.cancel()
        }
        
        request2.task = {
            $0.finish()
        }

        request3.task = {
            $0.finish()
        }

        queue.addOperation(request1)
        queue.addOperation(request2)
        queue.addOperation(request3)

        queue.completion = { _, _ in
            print("Request completed")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        print(queue.operations)
    }
}

