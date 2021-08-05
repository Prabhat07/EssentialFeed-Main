//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 05/08/21.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp timestamp: Date, completion: @escaping InsertCompletion) {

    }

    public func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        
    }

}
