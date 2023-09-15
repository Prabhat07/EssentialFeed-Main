//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 15/09/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }
}
