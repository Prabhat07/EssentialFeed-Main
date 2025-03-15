//
//  FeedEndPointTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 31/10/24.
//

import XCTest
import EssentialFeed

class FeedEndPointTests: XCTestCase {
    
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndpoint.get.url(baseUrl: baseURL)
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v1/feed", "path")
        XCTAssertEqual(received.query, "limit=10", "query")
    }
    
}
