//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 04/05/22.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timeStamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
}
