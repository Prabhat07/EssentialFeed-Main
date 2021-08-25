//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 25/01/21.
//

import Foundation

public protocol FeedLoader {
    
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping(Result) -> Void)
}
