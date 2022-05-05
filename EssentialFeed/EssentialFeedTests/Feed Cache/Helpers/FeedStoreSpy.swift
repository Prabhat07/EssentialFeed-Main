//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 25/05/21.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    private var deletionCompletions = [DeleteCompletion]()
    private var insertionCompletions = [InsertCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retriev
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCacheFeed(completion:@escaping DeleteCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completionDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion:@escaping InsertCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timeStamp))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccesfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retriev)
    }
    
    func completeRetrieval(with error: NSError, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timeStamp: Date,  at index: Int = 0) {
        retrievalCompletions[index](.success(CachedFeed(feed: feed, timeStamp:timeStamp)))
    }
}
