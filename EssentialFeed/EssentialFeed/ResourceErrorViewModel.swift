//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 01/04/22.
//

public struct ResourceErrorViewModel {
    
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
    
}
