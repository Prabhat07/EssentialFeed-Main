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

    func deleteCacheFeed(completion:@escaping DeleteCompletion)
    func save(_ feed: [LocalFeedImage], timeStamp: Date, completion:@escaping InsertCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

