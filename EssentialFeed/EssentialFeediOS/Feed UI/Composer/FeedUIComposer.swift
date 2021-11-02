//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 21/10/21.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: loader)
        let refreshController = FeedRereshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedImageIntoCellController(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedImageIntoCellController(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> () {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
            }
        }
    }
    
}

