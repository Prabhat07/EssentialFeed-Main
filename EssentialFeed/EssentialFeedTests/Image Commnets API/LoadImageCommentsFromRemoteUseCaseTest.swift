//
//  LoadImageCommentsFromRemoteUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 18/08/23.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTest: XCTestCase {

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

        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a user"
        )

        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another user"
        )

        let items = [item1.model, item2.model]

        let samples = [200, 201, 250, 280,  299]
        samples.enumerated().forEach { index, code in
            expect(sut, with: .success(items), when: {
                let json = makeJSONData([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }

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
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        
        let feedItem = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id": feedItem.id.uuidString,
            "message": feedItem.message,
            "created_at": createdAt.iso8601String,
            "author": ["username" : username]
        ]
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
