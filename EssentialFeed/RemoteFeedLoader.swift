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
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(comppletion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case .success:
                comppletion(.invalidData)
            case .failure:
                comppletion(.connectivity)
            }
        
        }
    }
    
}
