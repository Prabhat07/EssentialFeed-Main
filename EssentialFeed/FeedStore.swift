//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 21/05/21.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timeStamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeleteCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoke in any thread.
    /// Client are responsible to dispatch to appropriate threads, If needed.
    func deleteCacheFeed(completion:@escaping DeleteCompletion)
    
    /// The completion handler can be invoke in any thread.
    /// Client are responsible to dispatch to appropriate threads, If needed.
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion:@escaping InsertCompletion)
    
    /// The completion handler can be invoke in any thread.
    /// Client are responsible to dispatch to appropriate threads, If needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}

