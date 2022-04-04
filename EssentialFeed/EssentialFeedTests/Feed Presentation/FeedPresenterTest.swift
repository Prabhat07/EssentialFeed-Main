//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 03/04/22.
//

import XCTest
@testable import EssentialFeediOS

struct FeedErrorViewModel {
    
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

class FeedPresenter {
   
    let errorView: FeedErrorView
    
    init (errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
    
}

class FeedPresenterTest: XCTestCase {
    
    func test_init_doseNotSendMessageToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoading_showNoErrorMessage() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    //Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
