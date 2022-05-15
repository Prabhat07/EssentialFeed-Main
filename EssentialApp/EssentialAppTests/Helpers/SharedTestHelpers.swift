//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 14/05/22.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyUrl() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", url: anyUrl())]
}
