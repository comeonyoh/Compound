//
//  RequestsTests.swift
//  CompoundTests
//
//  Created by JungSu Kim on 2021/02/02.
//

import XCTest
@testable import Compound

class RequestsTests: XCTestCase {
    
    func testSimpleRequests() throws {

        var number = 0

        let queue = RequestQueue { (queue, error) in
            XCTAssertEqual(number, 50)
        }
        
        let request1 = Request {
            number += 5
            $0.finish()
        }
        let request2 = Request {
            number *= 10
            $0.finish()
        }
        
        let requests: Requests = [request1, request2]
        let request3 = Request {
            $0.finish()
        }

        queue.addOperations([requests, request3], waitUntilFinished: false)
    }
    
    func testRequestsTransmitData() throws {
     
        var number = 0

        let queue = RequestQueue { (queue, error) in
            XCTAssertEqual(number, 15)
            XCTAssertNotEqual(number, 50)
        }
        
        let request1 = Request {
            number += 5
            $0.parent?["plus"] = true
            $0.finish()
        }
        let request2 = Request {

            if let boolValue = $0.parent?["plus"] as? Bool, boolValue == true {
                number += 10
            }
            else {
                number *= 10
            }
            
            $0.finish()
        }
        
        let requests: Requests = [request1, request2]
        queue.addOperation(requests)
    }
    
    func testRequestsCancel() throws {

        var number = 0

        let queue = RequestQueue { (queue, error) in

            XCTAssertEqual(number, 5)

            if let error = error as? RequestError {
                XCTAssertEqual(error, RequestError.cancel)
            }
            else {
                XCTAssert(false, "Error type is incorrect")
            }
        }

        let request1 = Request {
            number += 5
            $0.cancel(RequestError.cancel)
        }

        let request2 = Request {
            number += 5
            $0.finish()
        }

        let requests: Requests = [request1, request2]
        queue.addOperation(requests)
    }

    func testRequestsCancelValidate() throws {
        
        var number = 0

        let queue = RequestQueue { (queue, error) in

            XCTAssertEqual(number, 10)
            XCTAssertNil(error)
        }

        let request1 = Request {
            number += 5
            $0.cancel(RequestError.cancel)
        }

        let request2 = Request {
            number += 5
            $0.finish()
        }

        let requests: Requests = [request1, request2]
        requests.cancelValidator = { _, error in
            
            //  If the error is just 'cancel' error, Let's keep going!
            if let error = error as? RequestError, error == RequestError.cancel {
                return false
            }
            
            return true
        }
        
        queue.addOperation(requests)
    }
}
