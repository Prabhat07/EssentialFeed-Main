//
//  CommnetsUIComposer.swift
//  EssentialApp
//
//  Created by Prabhat Tiwari on 24/05/24.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
            
        let presentationAdapter = FeedPresentationAdapter(
            loader: { commentsLoader().dispatchOnMainQueue() })
        
        let feedController = makeFeedViewController(title: FeedPresenter.title)
            feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(controller: feedController,
                                          imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher().dispatchOnMainQueue()}),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController  {
        let bundle = Bundle(for: ListViewController .self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
