//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 25/01/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failuer(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping(LoadFeedResult<Error>) -> Void)
}
