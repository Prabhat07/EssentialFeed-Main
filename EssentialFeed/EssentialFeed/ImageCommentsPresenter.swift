//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 15/09/23.
//

import Foundation

public class ImageCommentsPresenter {
   
    public static var title: String {
        let bundle = Bundle(for: Self.self)
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: bundle,
                                 comment: "Title for image comments view")
    }
    
}
