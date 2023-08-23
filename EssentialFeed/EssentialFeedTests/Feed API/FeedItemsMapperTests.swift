//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 26/01/21.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    
    func test_load_deliversErrorNon200HTTPResponse() throws {
        
        let samples = [199, 201, 300, 400,  500, 404]
        let data = makeJSONData([])
        try samples.forEach { code in
             XCTAssertThrowsError(
             try FeedItemsMapper.map(data, HTTPURLResponse(statusCode: code))
             )
            
        }
    }
    
    func test_load_deliversErrorWith200ResponseWithInvalidJson() {
        
        let data = "Invalid Json".data(using: .utf8)!
        XCTAssertThrowsError(
            try FeedItemsMapper.map(data, HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_load_deliversErrorWith200ResponseWithEmptyJsonlist() throws {
        
        let emptyListValidJson = makeJSONData([])
        
        let  result = try FeedItemsMapper.map(emptyListValidJson, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
        
    }
    
    func test_load_delivers200ResponseWithJsonData() throws {
                
        let item1 = makeItem(id: UUID(), imageUrl: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "A description",
                             location: "usa",
                             imageUrl: URL(string: "https://another-url.com")!)
        
        let items = [item1.model, item2.model]
        
        let json = makeJSONData([item1.json, item2.json])
        let  result = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, items)
        
    }
    
    //MARK: - Test Helpers
    
    private func failuer(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
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
   
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyUrl(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
