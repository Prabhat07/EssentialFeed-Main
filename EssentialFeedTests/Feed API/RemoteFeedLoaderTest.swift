//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 26/01/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_remoteFeedLoader_doesNotRequestDataFromUrl() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
   
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, with: failuer(.connectivity), when: {
            let error = NSError(domain: "Test", code: 0)
            client.complete(with: error)
        })
    }
    
    func test_load_deliversErrorNon200HTTPResponse() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 201, 300, 400,  500, 404]
        let data = makeJSONData([])
        samples.enumerated().forEach { index, code in
            expect(sut, with: failuer(.invalidData), when: {
                client.complete(withStatusCode: 400, data: data, at: index)
            })
        }
    }
    
    func test_load_deliversErrorWith200ResponseWithInvalidJson() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, with: failuer(.invalidData), when: {
            let data = "Invalid Json".data(using: .utf8)
            client.complete(withStatusCode: 400, data: data!)
        })
    }
    
    func test_load_deliversErrorWith200ResponseWithInvalidJsonlist() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, with: .success([])) {
            let emptyListValidJson = makeJSONData([])
            client.complete(withStatusCode: 200, data: emptyListValidJson)
        }
    }
    
    func test_load_delivers200ResponseWithJsonData() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageUrl: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "A description",
                             location: "usa",
                             imageUrl: URL(string: "https://another-url.com")!)
        
        let items = [item1.model, item2.model]
         
        expect(sut, with: .success(items), when: {
            let json = makeJSONData([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
        
    }
    
    func test_load_doNotDeliversResultWhenSUTHasBeenDeallocated() {
        let url = URL(string: "http://A-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSONData([]))
        
        XCTAssert(capturedResults.isEmpty)
        
    }
    
    //MARK: - Test Helpers
    
    func expect(_ sut: RemoteFeedLoader, with expectedResult: RemoteFeedLoader.Result, when action:() -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            
            case let (.success(receivedItems), .success(expectedItems)):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failuer(receivedError as RemoteFeedLoader.Error), .failuer(expectedError as RemoteFeedLoader.Error)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
            XCTFail("Expected result \(expectedResult) got \(receivedResult) insted", file: file, line: line)
                
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 2.0)
        
    }
    
    private func failuer(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failuer(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let feedItem = FeedItem(id: id, description: description, location: location, imageUrl: imageUrl)
        
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.imageUrl.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
     return (feedItem, json)
    }
    
    private func makeJSONData(_ jsonItems: [[String: Any]]) -> Data {
        let itemsJson = ["items": jsonItems]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }
   
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion:(HTTPClientResult) -> Void)]()
        var requestURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
        
    }
    
}
