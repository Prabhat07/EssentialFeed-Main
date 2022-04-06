//
//  FeedImagePresenterTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 06/04/22.
//

import XCTest

class FeedImagePresenter {
    init(view: Any) {
        
    }
}

class FeedImagePresenterTest: XCTestCase {

    func test_init_doseNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
    
}
