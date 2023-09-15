//
//  FeedImagePresenterTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 06/04/22.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTest: XCTestCase {

    func test_map_cereatesImageViewModle() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
    
}
