//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 30/08/23.
//

import Foundation

public final class FeedImageDataMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        return data
    }
    
}
