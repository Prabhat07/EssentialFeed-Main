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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                store.save(items, timeStamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    var deleteCacheCallCount = 0
    
    private var completions = [DeleteCompletion]()
    
    var insertions = [(items: [FeedItem], timeStamp: Date)]()
    
    func deleteCacheFeed(completion:@escaping DeleteCompletion) {
        deleteCacheCallCount += 1
        completions.append(completion)
    }
    
    func completionDeletion(with error: NSError, at index: Int = 0) {
        completions[index](error)
    }
    
    func deleteCacheSuccessfully(at index: Int = 0) {
        completions[index](nil)
    }
    
    func save(_ items: [FeedItem], timeStamp: Date) {
        insertions.append((items, timeStamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doseNotDeleteCache() {
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSut()
        
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }
    
    func test_save_doseNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSut()
        
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items)
        
        store.completionDeletion(with : deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestInsertionWithTimeStampWhenDeleteSuccessfully() {
        let timeStamp = Date()
        let (sut, store) = makeSut(currentDate: { timeStamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        store.deleteCacheSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items.count, items.count)
        XCTAssertEqual(store.insertions.first?.timeStamp, timeStamp)
        
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyUrl() -> URL {
        return URL(string: "https//:any-url/.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any Error", code: 0)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyUrl())
    }
    
    
}
