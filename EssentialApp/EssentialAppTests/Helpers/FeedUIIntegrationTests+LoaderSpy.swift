//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

class LoaderSpy {
   
    //MARK:- FeedLoader
    
    var feedRequests = [PassthroughSubject<[FeedImage], Error>]()
    
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        let publisher = PassthroughSubject<[FeedImage], Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index].send(feed)
        feedRequests[index].send(completion: .finished)
    }
    
    func completeLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "Any error", code: 0)
        feedRequests[index].send(completion: .failure(error))
    }
    
    //MARK: - FeedImageDataLoader
    private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
        let publisher = PassthroughSubject<Data, Error>()
        imageRequests.append((url, publisher))
        return publisher.handleEvents(receiveCancel: { [weak self] in
            self?.cancelledImageURLs.append(url)
        }).eraseToAnyPublisher()
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].publisher.send(imageData)
        imageRequests[index].publisher.send(completion: .finished)
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        imageRequests[index].publisher.send(completion: .failure(anyNSError()))
    }

}
