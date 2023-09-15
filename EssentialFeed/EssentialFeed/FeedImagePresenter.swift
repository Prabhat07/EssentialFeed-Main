//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 07/04/22.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
