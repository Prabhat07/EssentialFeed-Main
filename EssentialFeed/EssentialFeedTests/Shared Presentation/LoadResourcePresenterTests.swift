//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 10/09/23.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doseNotSendMessageToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoading_displayNoErrorMessageAndStartLoadingVeiw() {
        let (sut, view) = makeSUT()
        sut.didStartLoading()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    
    }
    
    func test_didFinishLoadingResource_displayResourceAndStopLoading() {
        let (sut, view) = makeSUT { resource in
            resource + " view model"
        }
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages,
                       [.display(resourceViewModel: "resource view model"),
                        .display(isLoading: false)])
    }
    
    func test_didFinishLoadingFeedWithError_displayLocalizedErrorMessageAndStopLoading() {
        
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("GENERIC_CONNECTION_ERROR"))])
        
    }
    
    
    //Helpers
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper:@escaping SUT.Mapper = { _ in "any"},
        file: StaticString = #file,
        line: UInt = #line) -> (SUT, ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceView: view, loadingView: view, errorView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
       let table = "Shared"
       let bundle = Bundle(for: SUT.self)
       let value = bundle.localizedString(forKey: key, value: nil, table: table)
       if value == key {
           XCTAssertNotEqual(key, value, "Missing localized string for Key: \(key), in table: \(table)", file: file, line: line)
       }
       return value
   }
    
    private class ViewSpy: ResourceView, ResourceLoadingView, ResourceErrorView {
        
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
        
    }
    

}
