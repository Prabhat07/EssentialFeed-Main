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
    
    func save(_ items: [FeedItem], completion: @escaping(Error?)->()) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                store.save(items, timeStamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void

    func deleteCacheFeed(completion:@escaping DeleteCompletion)
    func save(_ items: [FeedItem], timeStamp: Date, completion:@escaping InsertCompletion)
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doseNotReceivedMessageUponCereation() {
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSut()
        
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items){ _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doseNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSut()
        
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items){ _ in }
        
        store.completionDeletion(with : deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestInsertionWithTimeStampWhenDeleteSuccessfully() {
        let timeStamp = Date()
        let (sut, store) = makeSut(currentDate: { timeStamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items){ _ in }
        
        store.deleteCacheSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
        
    }
    
    func test_save_failOnDeletionError() {
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        expect(sut, completeWithError: deletionError, when: {
            store.completionDeletion(with : deletionError)
        })
    
    }
    
    func test_save_failOnInsertionError() {
        let (sut, store) = makeSut()
        let insertionError = anyNSError()
        
        expect(sut, completeWithError: insertionError, when: {
            store.deleteCacheSuccessfully()
            store.completeInsertion(with: insertionError)
        })
        
    }
    
    func test_save_succseedOnSuccessfullInsertion() {
        let (sut, store) = makeSut()
            
        expect(sut, completeWithError: nil, when: {
            store.deleteCacheSuccessfully()
            store.completeInsertionSuccesfully()
        })
        
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, completeWithError expectedError: NSError?, when completion:()->(), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        completion()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private class FeedStoreSpy: FeedStore {
        typealias DeleteCompletion = (Error?) -> Void
        typealias InsertCompletion = (Error?) -> Void
        private var deletionCompletions = [DeleteCompletion]()
        private var insertionCompletions = [DeleteCompletion]()
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        func deleteCacheFeed(completion:@escaping DeleteCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        
        func completionDeletion(with error: NSError, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func deleteCacheSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func save(_ items: [FeedItem], timeStamp: Date, completion:@escaping InsertCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timeStamp))
        }
        
        func completeInsertion(with error: NSError, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccesfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
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
