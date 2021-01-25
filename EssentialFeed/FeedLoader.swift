//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 25/01/21.
//

import Foundation

enum LoadFeedResult {
    case sucsess([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func laod(completion: @escaping(LoadFeedResult) -> Void)
}
