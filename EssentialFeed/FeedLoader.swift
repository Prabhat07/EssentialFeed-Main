//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 25/01/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error> 

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
