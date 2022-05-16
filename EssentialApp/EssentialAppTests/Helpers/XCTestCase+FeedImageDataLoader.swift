//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 16/05/22.
//

import XCTest
import EssentialFeed

protocol FeedImageDataloaderTestCase: XCTestCase {}

extension FeedImageDataloaderTestCase {
       func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> (), file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load feed")
        
        _ = sut.loadImageData(from: anyUrl()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
