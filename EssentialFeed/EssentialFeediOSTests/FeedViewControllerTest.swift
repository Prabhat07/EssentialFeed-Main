//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 18/09/21.
//

import XCTest

final class  FeedViewController {
    init(loader: FeedViewControllerTest.LoaderSpy) {
        
    }
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_dosenotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
 
    //MARK: - Helpers
    
    class LoaderSpy {
        let loadCallCount = 0
    }
}

