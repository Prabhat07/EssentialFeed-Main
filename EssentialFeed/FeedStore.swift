//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 21/05/21.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void

    func deleteCacheFeed(completion:@escaping DeleteCompletion)
    func save(_ feed: [LocalFeedImage], timeStamp: Date, completion:@escaping InsertCompletion)
    func retriev(completion: @escaping RetrievalCompletion)
}

