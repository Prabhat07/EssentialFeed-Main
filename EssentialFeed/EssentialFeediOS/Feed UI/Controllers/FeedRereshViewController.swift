//
//  FeedRereshViewController.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 19/10/21.
//

import UIKit
import EssentialFeed

final class FeedRereshViewController: NSObject {
     private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let feedLoader: FeedLoader?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> ())?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
    
}
