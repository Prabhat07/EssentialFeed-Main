//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 28/01/21.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failuer(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(comppletion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    comppletion(.success(items))
                } catch {
                    comppletion(.failuer(.invalidData))
                }
            case .failure:
                comppletion(.failuer(.connectivity))
            }
        
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failuer(.invalidData)
        }
    }
    
}

