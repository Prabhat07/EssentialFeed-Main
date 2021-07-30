//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 21/05/21.
//

import Foundation

public enum RetrievalCacheFeedResult {
    case failure(Error)
    case found(feed: [LocalFeedImage], timeStamp: Date)
    case empty
}

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalCacheFeedResult) -> Void

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

