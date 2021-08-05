//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 05/08/21.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoEffectOnRetrieveNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_delete_deletePreviousInsertedValues() {
        
    }
    
    func test_storeSideEffect_runSerially() {
        
    }
    
    // MARK - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
