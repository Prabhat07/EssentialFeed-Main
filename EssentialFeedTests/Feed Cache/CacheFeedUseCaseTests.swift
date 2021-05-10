//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 10/05/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed()
    }
}

class FeedStore {
    var deleteCacheCallCount = 0
    
    func deleteCacheFeed() {
        deleteCacheCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doseNotDeleteCache() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }
    
    
    // MARKS: - Helpers
    
    private func anyUrl() -> URL {
        return URL(string: "https//:any-url/.com")!
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyUrl())
    }
    
    
}
