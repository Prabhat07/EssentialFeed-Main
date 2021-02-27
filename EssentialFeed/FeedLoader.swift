//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 25/01/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failuer(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
