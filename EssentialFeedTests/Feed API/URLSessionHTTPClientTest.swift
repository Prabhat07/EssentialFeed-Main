//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 01/04/21.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(_ session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url, completionHandler: {_, _, _ in})
    }
    
}


class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromUrl_createDataTaskWithUrl() {
        let url = URL(string: "https//:any-url/.com")!
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        
        var receivedUrls = [URL]()
     
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
    
}
