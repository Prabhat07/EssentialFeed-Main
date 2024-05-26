//
//  CommentsUIIntegratiponTests.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 24/05/24.
//

import XCTest
import Combine
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class CommentsUIIntegratiponTests: FeedUIIntegrationTests {

    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadsCommentsActions_requestCommnetsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expect no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expect loaidng request when view is loaded")
        
        sut.simulateUserInitiateLoad()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expect another loaidng request when user initiates a load")
        
        sut.simulateUserInitiateLoad()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expect third laoding request when user initiates another load")
        
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLaodingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        //XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loaidng indicator once loadoing is completed successfully")
        
        sut.simulateUserInitiateLoad()
        //XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading inidcator once user initiates a load")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiates loaidng complete with error")
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "A Description", location: "location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiateLoad()
        loader.completeCommentsLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiateLoad()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    override func test_loadFeedCompletion_doseNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "A Description", location: "location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiateLoad()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiateLoad()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_laodFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any.url/")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    
    private class LoaderSpy {
        
        //MARK:- FeedLoader
        
        var requests = [PassthroughSubject<[FeedImage], Error>]()
        
        var loadCommentsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            requests[index].send(feed)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "Any error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }

}
