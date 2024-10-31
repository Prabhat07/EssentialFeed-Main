//
//  FeedViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
    
    public override func loadViewIfNeeded() {
         super.loadViewIfNeeded()
        
         tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
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
}

extension ListViewController {
    
    func numberOfRenderedComments() -> Int {
        return tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
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
        guard numberOfRenderedComments() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? ImageCommentCell
    }
    
    var commentsSection: Int {
        return 0
    }
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
        return tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImageSection)
    }
    
    var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
}

