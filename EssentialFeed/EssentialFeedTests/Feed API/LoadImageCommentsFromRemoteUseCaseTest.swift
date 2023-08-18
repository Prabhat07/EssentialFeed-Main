//
//  LoadImageCommentsFromRemoteUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 18/08/23.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTest: XCTestCase {

    func test_RemoteImageCommentsLoader_doesNotRequestDataFromUrl() {
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
    
    func test_load_deliversErrorNon2xxHTTPResponse() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 150, 300, 400,  500]
        let data = makeJSONData([])
        samples.enumerated().forEach { index, code in
            expect(sut, with: failuer(.invalidData), when: {
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_load_deliversErrorWith2xxResponseWithInvalidJson() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        let samples = [200, 201, 250, 280,  299]
        samples.enumerated().forEach { index, code in
            expect(sut, with: failuer(.invalidData), when: {
                let data = "Invalid Json".data(using: .utf8)
                client.complete(withStatusCode: code, data: data!, at: index)
            })
        }
    }
    
    func test_load_deliversErrorWith2xxResponseWithEmptyJsonlist() {
        let url = URL(string: "https://a-test.com")!
        let (sut, client) = makeSUT(url: url)
        let samples = [200, 201, 250, 280,  299]
        samples.enumerated().forEach { index, code in
            expect(sut, with: .success([])) {
                let emptyListValidJson = makeJSONData([])
                client.complete(withStatusCode: code, data: emptyListValidJson, at: index)
            }
        }
    }
    
    func test_load_delivers2xxResponseWithJsonData() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageUrl: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "A description",
                             location: "usa",
                             imageUrl: URL(string: "https://another-url.com")!)
        
        let items = [item1.model, item2.model]
         
        let samples = [200, 201, 250, 280,  299]
        samples.enumerated().forEach { index, code in
            expect(sut, with: .success(items), when: {
                let json = makeJSONData([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
        
    }
    
    func test_load_doNotDeliversResultWhenSUTHasBeenDeallocated() {
        let url = URL(string: "http://A-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSONData([]))
        
        XCTAssert(capturedResults.isEmpty)
        
    }
    
    //MARK: - Test Helpers
    
    func expect(_ sut: RemoteImageCommentsLoader, with expectedResult: RemoteImageCommentsLoader.Result, when action:() -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            
            case let (.success(receivedItems), .success(expectedItems)):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
            XCTFail("Expected result \(expectedResult) got \(receivedResult) insted", file: file, line: line)
                
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 2.0)
        
    }
    
    private func failuer(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
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
   
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    

}