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
    
    func test_laod_requestCacheRetrieval() {
        let (sut, store) = makeSut()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_laod_failsOnRetrievalError() {
        let (sut, store) = makeSut()
        let retrievalError = anyNSError()
        expect(sut, completeWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_laod_noImageFeedReturnOnEmptyCache() {
        let (sut, store) = makeSut()
        expect(sut, completeWith: .success([]), when: {
            store.completeWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesOnNonExpireCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpireTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        
        expect(sut, completeWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timeStamp: nonExpireTimestamp)
        })
    }
    
    func test_laod_noImagesDeliversOnExpirationCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        expect(sut, completeWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timeStamp: expirationTimeStamp)
        })
    }
    
    func test_laod_noImagesDeliversOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        expect(sut, completeWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timeStamp: expiredTimestamp)
        })
    }
    
    func test_load_noSideEffectOnRetrievalError() {
        let (sut, store) = makeSut()
        let retrieveError = anyNSError()
        
        sut.load { _ in }
        
        store.completeRetrieval(with: retrieveError)
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSut()
        sut.load { _ in }
        
        store.completeWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_load_hasNoSideEffectOnNonExpireCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpireTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: nonExpireTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_load_hasNoSideEffectOnExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }

    func test_load_doseNotReceivedAnyMessageWheSutGetDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedMessages = [LocalFeedLoader.LoadResult]()
        
        sut?.load { receivedMessages.append($0) }
        sut = nil

        store.completeWithEmptyCache()
        XCTAssertTrue(receivedMessages.isEmpty)
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: FeedLoader.Result, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for laod completion")
        sut.load { receivedresult in
            switch (receivedresult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedresult), instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
