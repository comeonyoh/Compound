//
//  ViewController.swift
//  Compound
//
//  Created by JungSu Kim on 2021/01/31.
//

import UIKit

struct Sample: Decodable {
    var title: String
}

class ViewController: UIViewController {

    var queue: NetworkQueue!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        queue = NetworkQueue(configuration: .default) { queue, error in
            print("COMLETED!!!")
        }
        
        let req1 = Network(path: "https://hacker-news.firebaseio.com/v0/item/1000.json")
        req1.customCompletion = { request, error in
            print("\(String(describing: try? JSONDecoder().decode(Sample.self, from: (request as? Network)!.responseData!)))")
        }

        let req2 = Network(path: "https://hacker-news.firebaseio.com/v0/item/1001.json")
        req2.customCompletion = { request, error in
            print("\(String(describing: try? JSONDecoder().decode(Sample.self, from: (request as? Network)!.responseData!)))")
        }

        req1.name = "REQ_1"
        req2.name = "REQ_2"
        
        queue.addOperation(req1)
        queue.addOperation(req2)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        print(queue.operations)
    }
}

