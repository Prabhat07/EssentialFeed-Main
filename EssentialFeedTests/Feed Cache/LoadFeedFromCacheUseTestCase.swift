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
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        
        expect(sut, completeWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysOldTimestamp)
        })
    }
    
    func test_laod_noImagesDeliversOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevendayOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        expect(sut, completeWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timeStamp: sevendayOldTimeStamp)
        })
    }
    
    func test_laod_noImagesDeliversOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        expect(sut, completeWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timeStamp: moreThanSevenDaysOldTimestamp)
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
    
    func test_load_hasNoSideEffectOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_load_hasNoSideEffectOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_load_hasNoSideEffectOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timeStamp: moreThanSevenDaysOldTimestamp)
        
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
    
    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: LoadFeedResult, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
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
