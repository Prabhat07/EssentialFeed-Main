//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 22/05/21.
//

import Foundation

 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
