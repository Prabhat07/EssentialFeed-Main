//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 01/04/22.
//

public struct FeedErrorViewModel {
    
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
    
}
