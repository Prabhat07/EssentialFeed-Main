//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 15/09/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    //Helpers
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTAssertNotEqual(key, value, "Missing localized string for Key: \(key), in table: \(table)", file: file, line: line)
        }
        return value
   }

}
