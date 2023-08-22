//
//  RemoteLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 20/08/23.
//

import XCTest
import EssentialFeed

final class RemoteLoaderTest: XCTestCase {

    func test_RemoteLoader_doesNotRequestDataFromUrl() {
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

    
    func test_load_deliversErrorOnMapperError() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url, mapper: {_ ,_ in
            throw anyNSError()
        })
        
        expect(sut, with: failuer(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyData())
        }
    }
    
    func test_load_deliversMappedResource() {
        let resource = "any string"
        let (sut, client) = makeSUT(mapper: { data , _ in
            String(data: data, encoding: .utf8)!
        })
         
        expect(sut, with: .success(resource), when: {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        })
        
    }
    
    func test_load_doNotDeliversResultWhenSUTHasBeenDeallocated() {
        let url = URL(string: "http://A-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: {_, _ in "any"})
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSONData([]))
        
        XCTAssert(capturedResults.isEmpty)
        
    }
    
    //MARK: - Test Helpers
    
    func expect(_ sut: RemoteLoader<String>, with expectedResult: RemoteLoader<String>.Result, when action:() -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            
            case let (.success(receivedItems), .success(expectedItems)):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
            XCTFail("Expected result \(expectedResult) got \(receivedResult) insted", file: file, line: line)
                
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 2.0)
        
    }
    
    private func failuer(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedImage, json: [String: Any]) {
        
        let feedItem = FeedImage(id: id, description: description, location: location, url: imageUrl)
        
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.url.absoluteString
        ].compactMapValues { $0 }
     return (feedItem, json)
    }
    
    private func makeJSONData(_ jsonItems: [[String: Any]]) -> Data {
        let itemsJson = ["items": jsonItems]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }
   
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any"},
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper:mapper)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

}
