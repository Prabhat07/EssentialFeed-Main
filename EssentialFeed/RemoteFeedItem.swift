//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 22/05/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
