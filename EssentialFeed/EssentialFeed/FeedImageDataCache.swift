//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 16/05/22.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
