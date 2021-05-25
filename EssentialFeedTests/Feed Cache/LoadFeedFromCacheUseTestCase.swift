//
//  LoadFeedFromCacheUseTestCase.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 25/05/21.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseTestCase: XCTestCase {

    func test_init_doseNotReceivedMessageUponCereation() {
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    
}
