//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 05/06/21.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
      
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffect()
    }
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    } 
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetrive: .found(feed: feed, timeStamp: timeStamp))
    }

    func test_retrieve_hasNoEffectOnRetrieveNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed, timeStamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timeStamp: timeStamp))
    }

    func test_retrieve_deliversFailuerOnRetrievalError() {
        let storeURL = testSpecificStoreUrl()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrive: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailuer() {
        let storeURL = testSpecificStoreUrl()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValue() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestTimeStamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let storeURL = URL(string: "invalid://test-store-url")!
        let sut = makeSUT(storeURL: storeURL)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Delete Cache SuccessFully")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deletePreviousInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed, timeStamp), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected delete cache duccessFully")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Ecpected delete dache failed")
    }
    
    //MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: storeURL ?? testSpecificStoreUrl())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache:(feed: [LocalFeedImage], timeStamp: Date), to sut: FeedStore,  file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timeStamp)  { receiveError in
            insertionError = receiveError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrievalCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult)
        expect(sut, toRetrive: expectedResult)
    }
    
    private func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievalCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
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
    
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for Delete Completion")
        var receivedError: Error?
        sut.deleteCacheFeed { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffect() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreUrl())
    }
    
    func testSpecificStoreUrl() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
