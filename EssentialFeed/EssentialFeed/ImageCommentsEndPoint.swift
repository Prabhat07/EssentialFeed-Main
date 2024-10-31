//
//  ImageCommentsEndPoint.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 31/10/24.
//

import Foundation

public enum ImageCommentsEndPoint {
    case get(UUID)
    
    public func url(baseUrl: URL) -> URL {
        switch self {
        case let .get(id):
            baseUrl.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}
