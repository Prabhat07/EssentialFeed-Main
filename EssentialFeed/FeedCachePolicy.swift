//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 02/06/21.
//

import Foundation

internal final class FeedCachePolicy {
    
    private init() { }
    
    private static let calender = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays : Int {
        return 7
    }
    
    internal static func validate(_ timeStamp: Date, against date: Date) -> Bool {
        guard let maxAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
        return date < maxAge
    }
}
