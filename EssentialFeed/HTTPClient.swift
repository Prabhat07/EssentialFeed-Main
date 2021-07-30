//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 07/02/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoke in any thread.
    /// Client are responsible to dispatch to appropriate threads, If needed.
    func get(from url: URL, completion:@escaping (HTTPClientResult) -> Void)
}
