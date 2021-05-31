//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 10/05/21.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doseNotReceivedMessageUponCereation() {
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSut()
            
        sut.save(uniqueImageFeed().models){ _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doseNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSut()
        
        let feed = uniqueImageFeed()
        let deletionError = anyNSError()
        sut.save(feed.models){ _ in }
        
        store.completionDeletion(with : deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestInsertionWithTimeStampWhenDeleteSuccessfully() {
        let timeStamp = Date()
        let (sut, store) = makeSut(currentDate: { timeStamp })
        
        let feed = uniqueImageFeed()
        
        sut.save(feed.models){ _ in }
        
        store.deleteCacheSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timeStamp)])
        
    }
    
    func test_save_failOnDeletionError() {
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completionDeletion(with : deletionError)
        })
    
    }
    
    func test_save_failOnInsertionError() {
        let (sut, store) = makeSut()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.deleteCacheSuccessfully()
            store.completeInsertion(with: insertionError)
        })
        
    }
    
    func test_save_succseedOnSuccessfullInsertion() {
        let (sut, store) = makeSut()
            
        expect(sut, toCompleteWithError: nil, when: {
            store.deleteCacheSuccessfully()
            store.completeInsertionSuccesfully()
        })
        
    }
    
    func test_save_doseNotDeliverDeletionErrorWhenSutGetDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models) { receivedResult.append($0) }
        
        sut = nil
        store.completionDeletion(with: anyNSError())
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doseNotDeliverInsertionErrorWhenSutGetDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models) { receivedResult.append($0) }
        
        store.deleteCacheSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action:()->(), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(uniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
}
