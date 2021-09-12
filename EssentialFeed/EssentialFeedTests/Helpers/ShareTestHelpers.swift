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
