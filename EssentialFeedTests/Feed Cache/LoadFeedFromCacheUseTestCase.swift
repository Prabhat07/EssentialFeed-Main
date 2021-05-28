//
//  LoadFeedFromCacheUseTestCase.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 25/05/21.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseTestCase: XCTestCase {

    func test_init_doseNotReceivedMessageUponCereation() {
        let (_, store) = makeSut()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_laod_requestCacheRetrieval() {
        let (sut, store) = makeSut()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retriev])
    }
    
    func test_laod_failsOnRetrievalError() {
        let (sut, store) = makeSut()
        let retrievalError = anyNSError()
        expect(sut, completeWith: .failuer(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_laod_noImageFeedReturnOnEmptyCache() {
        let (sut, store) = makeSut()
        expect(sut, completeWith: .success([]), when: {
            store.completeWithEmptyCache()
        })
    }
    
    // MARKS: - Helpers
    
    private func makeSut(currentDate:@escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: LoadFeedResult, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for laod completion")
        sut.load { receivedresult in
            switch (receivedresult, expectedResult) {
                case let (.success(receivedImages), .success(expectedImages)):
                    XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failuer(receivedError as NSError), .failuer(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedresult), instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any Error", code: 0)
    }
    
}
