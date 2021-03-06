//
//  FeedImagePresenterTest.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 06/04/22.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTest: XCTestCase {

    func test_init_doseNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_didStartLoadingImageData_displayLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
            let image = uniqueImage()
            let (sut, view) = makeSUT()

            sut.didFinishLoadingImageData(with: anyNSError(), for: image)

            let message = view.messages.first
            XCTAssertEqual(view.messages.count, 1)
            XCTAssertEqual(message?.description, image.description)
            XCTAssertEqual(message?.location, image.location)
            XCTAssertEqual(message?.isLoading, false)
            XCTAssertEqual(message?.shouldRetry, true)
            XCTAssertNil(message?.image)
        }
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter<ViewSpy, AnyImage>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    
}
