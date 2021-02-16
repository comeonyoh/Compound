//
//  ViewController.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import UIKit

class ViewController: UIViewController {

    var queue: NetworkQueue!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        queue = NetworkQueue(configuration: .default) { queue, error in
        
        }
        
        let req1 = Network(path: "https://hacker-news.firebaseio.com/v0/item/1000.json")
        
        queue.addOperation(req1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        print(queue.operations)
    }
}

