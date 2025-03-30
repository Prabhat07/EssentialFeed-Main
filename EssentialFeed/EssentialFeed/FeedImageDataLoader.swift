//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 14/10/21.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
