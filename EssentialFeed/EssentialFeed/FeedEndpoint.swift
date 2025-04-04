//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 31/10/24.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedImage? = nil)
    
    public func url(baseUrl: URL) -> URL {
        switch self {
        case let .get(image):
            var components = URLComponents()
            components.scheme = baseUrl.scheme
            components.host = baseUrl.host
            components.path = baseUrl.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                image.map {URLQueryItem(name: "after_id", value: $0.id.uuidString)}
            ].compactMap { $0 }
            return components.url!
        }
    }
}
