//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 14/10/21.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> ()) -> FeedImageDataLoaderTask
}
