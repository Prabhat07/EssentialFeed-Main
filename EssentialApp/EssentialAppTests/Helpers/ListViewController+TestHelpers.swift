//
//  FeedViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    
    func simulateAppearance() {
            if !isViewLoaded {
                loadViewIfNeeded()
                prepareForFirstAppearance()
            }
            
            beginAppearanceTransition(true, animated: false)
            endAppearanceTransition()
        }
        
        private func prepareForFirstAppearance() {
            setSmallFrameToPreventRenderingCells()
            replaceRefreshControlWithFakeForiOS17PlusSupport()
        }
        
        private func setSmallFrameToPreventRenderingCells() {
            tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
        }
        
        private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
            let fakeRefreshControl = FakeRefreshControl()
            
            refreshControl?.allTargets.forEach { target in
                refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                    fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
                }
            }
            
            refreshControl = fakeRefreshControl
        }
        
    
    func simulateUserInitiateLoad() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var errorMessage: String? {
        return errorView.message
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var isShowingLoadingIndicator: Bool {
        return self.refreshControl?.isRefreshing == true
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension ListViewController {
    
    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }
    
    func commentMessage(at row:Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row:Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row:Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
       cell(row: row, section: commentsSection) as? ImageCommentCell
    }
    
    var commentsSection: Int { 0 }
}
   
extension ListViewController {
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateTapOnFeedImage(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImageSection)
    }
    
    var feedImageSection: Int { 0 }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImageSection)
    }
    
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    public override var isRefreshing: Bool { _isRefreshing }
    
    public override func beginRefreshing() {
        _isRefreshing = true
    }
    
    public override func endRefreshing() {
        _isRefreshing = false
    }
}
