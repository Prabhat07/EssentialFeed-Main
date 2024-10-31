//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 31/10/24.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseUrl: URL) -> URL {
        switch self {
        case .get:
            baseUrl.appendingPathComponent("/v1/feed")
        }
    }
}
