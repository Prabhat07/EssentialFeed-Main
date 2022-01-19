//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 02/11/21.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
