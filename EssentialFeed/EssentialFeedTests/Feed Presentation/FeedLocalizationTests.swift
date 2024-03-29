//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 27/02/22.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }

}

