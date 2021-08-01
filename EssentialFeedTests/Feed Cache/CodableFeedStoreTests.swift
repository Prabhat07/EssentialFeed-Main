//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 05/06/21.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailbleFeedStore {

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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestTimeStamp))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        
        insert((latestFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrive: .found(feed: latestFeed, timeStamp: latestTimestamp))
    }

    
    func test_insert_deliversErrorOnInsertionError() {
        let storeURL = URL(string: "invalid://test-store-url")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        let insertionError = insert((feed, timeStamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let storeURL = URL(string: "invalid://test-store-url")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed, timeStamp), to: sut)
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Delete Cache SuccessFully")
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_deletePreviousInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed, timeStamp), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Ecpected delete dache failed")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        expect(sut, toRetrive: .empty)
    }
    
    func test_storeSideEffect_runSerially() {
        let sut = makeSUT()
        
        var completionOperationsInorder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completionOperationsInorder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation2")
        sut.deleteCacheFeed { _ in
            completionOperationsInorder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completionOperationsInorder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler:nil)
        
        XCTAssertEqual(completionOperationsInorder, [op1, op2, op3], "Expect side-effect run serially but operation finished in wrong order")
        
    }
    
    //MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: storeURL ?? testSpecificStoreUrl())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
    
    private func testSpecificStoreUrl() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
