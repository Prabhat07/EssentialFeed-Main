//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 18/09/21.
//

import XCTest
import EssentialFeed

final class FeedViewController: UIViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
    }
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_dosenotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
 
    func test_viewDidLoad_LoadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: - Helpers
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }


}
