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
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let comments = [
            ImageComment(id: UUID(),
                         message: "a message",
                         createdAt: now.adding(minutes: -5, calendar: calendar),
                         username: "a username"),
            ImageComment(id: UUID(),
                         message: "another message",
                         createdAt: now.adding(days: -1, calendar: calendar),
                         username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(comments,
                                                   cureentDate: now,
                                                   calendar: calendar,
                                                   locale: locale
        )
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommnetViewModel(message: "a message",
                                  date:"5 minutes ago",
                                  userName: "a username"),
            ImageCommnetViewModel(message: "another message",
                                  date:"1 day ago",
                                  userName: "another username")
        ])
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
