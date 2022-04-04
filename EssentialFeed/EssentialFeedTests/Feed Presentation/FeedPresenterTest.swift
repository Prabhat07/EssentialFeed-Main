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
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
