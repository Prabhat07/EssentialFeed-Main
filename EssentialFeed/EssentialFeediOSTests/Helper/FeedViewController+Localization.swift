//
//  FeedViewController+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 27/02/22.
//

import Foundation
import XCTest
import EssentialFeediOS

extension FeedViewControllerTest {
     func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTAssertNotEqual(key, value, "Missing localized string for Key: \(key), in table: \(table)", file: file, line: line)
        }
        return value
    }
    
}

