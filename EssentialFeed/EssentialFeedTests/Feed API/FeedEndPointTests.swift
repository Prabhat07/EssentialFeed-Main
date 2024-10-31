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
            let expected = URL(string: "http://base-url.com/v1/feed")!

            XCTAssertEqual(received, expected)
        }

}
