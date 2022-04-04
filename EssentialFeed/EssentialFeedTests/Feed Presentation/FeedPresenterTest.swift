//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 03/04/22.
//

import XCTest

class FeedPresenter {
        
    init (view: Any) {
    }
}

class FeedPresenterTest: XCTestCase {
    
    func test_init_doseNotSendMessageToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //Helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
