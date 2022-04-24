//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 24/04/22.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url) { _ in }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doseNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestURLs, [url])
        
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyUrl(), file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestURLs.append(url)
        }
    }

}
