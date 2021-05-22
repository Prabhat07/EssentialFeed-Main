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

    func deleteCacheFeed(completion:@escaping DeleteCompletion)
    func save(_ items: [LocalFeedItem], timeStamp: Date, completion:@escaping InsertCompletion)
}

