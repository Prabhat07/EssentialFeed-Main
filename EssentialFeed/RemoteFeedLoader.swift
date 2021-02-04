//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 28/01/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion:@escaping (HTTPClientResult) -> Void)
}

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
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    comppletion(.success(root.items))
                } else {
                    comppletion(.failuer(.invalidData))
                }
            case .failure:
                comppletion(.failuer(.connectivity))
            }
        
        }
    }
    
}

private struct Root: Decodable {
    let items: [FeedItem]
}
