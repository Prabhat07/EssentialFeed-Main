//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    //MARK:- FeedLoader
    
    var feedRequests = [(FeedLoader.Result) -> ()]()
    
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeLaodingWithError(at index: Int = 0) {
        let error = NSError(domain: "Any error", code: 0)
        feedRequests[index](.failure(error))
    }
    
    //MARK: - FeedImageDataLoader
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallBack: () -> ()?
        public func cancel() {
            cancelCallBack()
        }
    }
    
    private var imageRequests = [(url: URL, completion:(FeedImageDataLoader.Result) -> ())]()
    
    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "Any Error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
