//
//  FeedViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 18/09/21.
//

import XCTest
import EssentialFeed

final class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_loadsFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expect no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expect loaidng request when view is loaded")
        
        sut.simulateUserInitiateFeedLaod()
        XCTAssertEqual(loader.loadCallCount, 2, "Expect another loaidng request when user initiates a load")

        sut.simulateUserInitiateFeedLaod()
        XCTAssertEqual(loader.loadCallCount, 3, "Expect third laoding request when user initiates another load")

    }
    
    func test_loadingFeedIndicator_isVisibleWhileLaodingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator once view is loaded")
    
        loader.completeLaoding(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loaidng indicator once loadoing is completed")
        
        sut.simulateUserInitiateFeedLaod()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading inidcator once user initiates a load")
        
        loader.completeLaoding(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator once user initiates loaidng is completed")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        var completions = [(FeedLoader.Result) -> ()]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLaoding(at index: Int) {
            completions[index](.success([]))
        }
    }


}

private extension FeedViewController {
    func simulateUserInitiateFeedLaod() {
        self.refreshControl?.simulatePullToResfresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return self.refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    
    func simulatePullToResfresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        })
    }
    
}
