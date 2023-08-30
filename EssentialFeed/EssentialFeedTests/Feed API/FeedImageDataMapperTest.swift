//
//  FeedImageDataMapperTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 30/08/23.
//

import XCTest
import EssentialFeed

final class FeedImageDataMapperTest: XCTestCase {
    
    func test_map_deliversInvalidDataErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        
        try samples.enumerated().forEach { index, code in
            XCTAssertThrowsError(
               try FeedImageDataMapper.map(anyData(), HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        
        XCTAssertThrowsError(
           try FeedImageDataMapper.map(emptyData, HTTPURLResponse(statusCode: 200))
        )
    
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty data".utf8)
        
        let result = try FeedImageDataMapper.map(nonEmptyData, HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, nonEmptyData)
    }
    
}
