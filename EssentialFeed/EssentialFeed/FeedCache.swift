//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 16/05/22.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping(SaveResult)->())
}
