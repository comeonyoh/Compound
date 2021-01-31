//
//  RequestTests.swift
//  CompoundTests
//
//  Created by JungSu Kim on 2021/01/31.
//

import XCTest
@testable import Compound

class RequestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMultipleRequestsSequentially() throws {

        var number = 10

        let queue1 = RequestQueue()
        let queue2 = RequestQueue()
        
        let req1 = Request()
        req1.task = {
            number += 5
            $0.finish()
        }
        
        let req2 = Request()
        req1.task = {
            number *= 10
            $0.finish()
        }
        
        let req3 = Request()
        req1.task = {
            number += 5
            $0.finish()
        }
        
        let req4 = Request()
        req1.task = {
            number *= 10
            $0.finish()
        }

        queue1.addOperation(req1)
        queue1.addOperation(req2)

        queue2.addOperation(req4)
        queue2.addOperation(req3)

        queue1.completion = { _, _ in
            XCTAssert(number == 150)
        }

        queue2.completion = { _, _ in
            XCTAssert(number == 105)
        }
    }
    
    func testFractionCompleted() throws {
        
        let queue = RequestQueue()
        
        let req1 = Request()
        let req2 = Request()
        let req3 = Request()
        let req4 = Request()
        
        req1.task = {
            $0.finish()
        }
        
        req2.task = {
            $0.cancel()
        }
        
        req3.task = {
            
            XCTAssert($0.queue?.progress.fractionCompleted == 0.5)
            $0.cancel()
            XCTAssert($0.queue?.progress.fractionCompleted == 0.75)
        }
        
        req4.task = {
            $0.finish()
        }
    
        queue.addOperation(req1)
        queue.addOperation(req2)
        queue.addOperation(req3)
        queue.addOperation(req4)
        
        queue.completion = {
            _, _ in
            print("Completed")
        }
    }
}
