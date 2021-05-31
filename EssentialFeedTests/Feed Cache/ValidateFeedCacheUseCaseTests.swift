//
//  File.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 31/05/21.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doseNotReceivedMessageUponCereation() {
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSut()
        let retrieveError = anyNSError()
        
        sut.validateCache()
        
        store.completeRetrieval(with: retrieveError)
        
        XCTAssertEqual(store.receivedMessages, [.retriev, .deleteCachedFeed])
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any Error", code: 0)
    }
}
