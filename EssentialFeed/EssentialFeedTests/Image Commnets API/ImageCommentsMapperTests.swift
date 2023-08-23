//
//  LoadImageCommentsFromRemoteUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 18/08/23.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {

    func test_map_throwsErrorNon2xxHTTPResponse() throws {
        let data = makeJSONData([])
        let samples = [199, 150, 300, 400,  500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(data, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwErrorWith2xxResponseWithInvalidJson() throws {
        let data = "Invalid Json".data(using: .utf8)!
        let samples = [200, 201, 250, 280,  299]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(data, HTTPURLResponse(statusCode: code))
            )
        }
        
    }
    
    func test_map_deliversErrorWith2xxResponseWithEmptyJsonlist() throws {
        let emptyListValidJson = makeJSONData([])
        let samples = [200, 201, 250, 280,  299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListValidJson, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
        
    }
    
    func test_map_delivers2xxResponseWithJsonData() throws {

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

        let json = makeJSONData([item1.json, item2.json])
        let samples = [200, 201, 250, 280,  299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }

    }
    
    //MARK: - Test Helpers

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

}
