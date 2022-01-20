//
//  FeedRereshViewController.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 19/10/21.
//

import UIKit

protocol FeedRereshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRereshViewController: NSObject, FeedLoadingView {
    @IBOutlet private var view: UIRefreshControl?
        
    var delegate: FeedRereshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }

}
