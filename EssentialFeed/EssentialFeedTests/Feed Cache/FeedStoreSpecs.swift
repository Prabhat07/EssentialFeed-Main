//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 31/07/21.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliverEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoEffectOnRetrieveNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_hasNoSideEffectOnEmptyCache()
    func test_delete_deletePreviousInsertedValues()
    
    func test_storeSideEffect_runSerially()
}

protocol FailableRetrieveProtocol: FeedStoreSpecs {
    func test_retrieve_deliversFailuerOnRetrievalError()
    func test_retrieve_hasNoSideEffectOnFailuer()
}

protocol FailableInsertProtocol: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteProtocol: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailbleFeedStore = FailableInsertProtocol & FailableDeleteProtocol & FailableRetrieveProtocol
