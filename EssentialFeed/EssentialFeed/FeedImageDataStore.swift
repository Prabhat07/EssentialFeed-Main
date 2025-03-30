//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 03/05/22.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
