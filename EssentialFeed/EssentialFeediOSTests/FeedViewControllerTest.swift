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
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc private func load() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_dosenotLoadFeed() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
    }
 
    func test_viewDidLoad_LoadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
         sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullToResfresh()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.refreshControl?.simulatePullToResfresh()
        XCTAssertEqual(loader.loadCallCount, 3)

    }
    
    func test_viewDidLoad_showLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLaoding()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_pullToRefresh_showLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.refreshControl?.simulatePullToResfresh()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_pullToRefresh_hideLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.refreshControl?.simulatePullToResfresh()
        loader.completeLaoding()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
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
        
        func completeLaoding() {
            completions[0](.success([]))
        }
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
