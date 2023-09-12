//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 05/04/22.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public class FeedPresenter {
   
    public static var title: String {
        let bundle = Bundle(for: FeedPresenter.self)
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: bundle, comment: "Title for feed view")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
    
}
