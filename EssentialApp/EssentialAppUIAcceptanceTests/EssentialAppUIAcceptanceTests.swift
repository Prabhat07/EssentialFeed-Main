//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Prabhat Tiwari on 26/05/22.
//

import XCTest

class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_onLaunch_dispalyCachedRemoteFeedWhenCustomerHasNoConectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)
        
        let cachedFirstImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(cachedFirstImage.exists)
    }
    
    func test_onLaunch_displayEmptyFeedWhenCustomerHasNoConnectivityAndNoCached() {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-reset", "-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 0)
    }
}
