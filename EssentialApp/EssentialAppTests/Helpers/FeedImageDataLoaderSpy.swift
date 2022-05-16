//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 16/05/22.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private(set) var messages = [(url: URL, completion:(FeedImageDataLoader.Result) -> Void)]()
    
    private(set) var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    struct Task: FeedImageDataLoaderTask {
        var callback: () -> ()?
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
}
