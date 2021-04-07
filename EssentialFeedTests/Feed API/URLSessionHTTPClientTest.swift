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
    
    init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedErrorReprsentation: Error {}
    
    func get(from url: URL, compilationHandler: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) {data, response, error in
            if let error = error {
                compilationHandler(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                compilationHandler(.success(data, response))
            } else {
                compilationHandler(.failure(UnexpectedErrorReprsentation()))
            }
        }.resume()
    }
    
}


class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRquest()

    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyUrl()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSut().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromUrl_failsonRequestError() {
        let error = NSError(domain: "Any error", code: 0)
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)
        
        XCTAssertEqual((receivedError! as NSError).domain, error.domain)
        XCTAssertEqual((receivedError! as NSError).code, error.code)
           
    }
    
    func test_getFromUrl_failsonAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromUrl_succseedOnHTTPUrlResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        let exp = expectation(description: "Wait for complition")
        makeSut().get(from: anyUrl()) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result) insted")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func anyUrl() -> URL {
        return URL(string: "https//:any-url/.com")!
    }
    
    private func anyData() -> Data {
        return Data("Any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any Error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSut(file: file, line: line)
        let exp = expectation(description: "Wait for complition")
        var receivedError: Error?
        sut.get(from: anyUrl()) { result in
            switch result {
            case  let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got instead \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stubs: Stub?
        
        private static var requestObserve: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stubs = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRquest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
            requestObserve = nil
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserve = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserve?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stubs else {
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
