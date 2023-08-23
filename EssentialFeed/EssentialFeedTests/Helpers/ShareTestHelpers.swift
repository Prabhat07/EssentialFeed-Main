//
//  ShareTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 31/05/21.
//

import Foundation

func anyUrl() -> URL {
    return URL(string: "https//:any-url/.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "Any Error", code: 0)
}

func anyData() -> Data {
    return Data("any data".utf8)
}


func makeJSONData(_ jsonItems: [[String: Any]]) -> Data {
    let itemsJson = ["items": jsonItems]
    return try! JSONSerialization.data(withJSONObject: itemsJson)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyUrl(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
