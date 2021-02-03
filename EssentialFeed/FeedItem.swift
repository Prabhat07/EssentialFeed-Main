//
//  FeetItem.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 23/01/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
