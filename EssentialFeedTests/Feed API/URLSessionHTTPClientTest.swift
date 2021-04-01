//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 01/04/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(_ session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, compilationHandler: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) {_, _, error in
            if let error = error {
                compilationHandler(.failure(error))
            }
        }.resume()
    }
    
}


class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromUrl_resumeDataTaskWithUrl() {
        let url = URL(string: "https//:any-url/.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session)
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromUrl_failsonRequestError() {
        let url = URL(string: "https//:any-url/.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "Any error", code: 0)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session)
        
        let exp = expectation(description: "Wait for complition")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("expected failuer error \(error) got instead \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: NSError?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: NSError? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("no stubs for given \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }

}
