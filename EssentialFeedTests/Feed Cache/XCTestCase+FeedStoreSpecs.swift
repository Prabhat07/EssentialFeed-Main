//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 01/08/21.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(_ cache:(feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore,  file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp)  { receiveError in
            insertionError = receiveError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for Delete Completion")
        var receivedError: Error?
        sut.deleteCacheFeed { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrievalCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult)
        expect(sut, toRetrive: expectedResult)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievalCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve { retrieveResult in
            switch (expectedResult, retrieveResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimeStamp), .found(receivedFeed, receivedTimeStamp)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimeStamp, receivedTimeStamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrieveResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
}
