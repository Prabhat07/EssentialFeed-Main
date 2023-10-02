//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 01/10/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }

    // MARK: - Helpers
    
    func makeSUT(fiel: StaticString = #file, line: UInt = #line) -> ListViewController {
        
        let bundel = Bundle(for: ListViewController.self)
        let storyBoard = UIStoryboard(name: "ImageComments", bundle: bundel)
        let controller = storyBoard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func comments() -> [CellController] {
        commentControllers().map { CellController($0) }
    }
    
    private func commentControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommnetViewModel(message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                                             date: "1000 years ago",
                                             userName: "a very long long long username")
            ),
            ImageCommentCellController(
                model: ImageCommnetViewModel(message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                                             date: "10 days ago",
                                             userName: "a username")
            ),
            ImageCommentCellController(
                model: ImageCommnetViewModel(message: "nice",
                                             date: "1 hour ago",
                                             userName: "a.")
            )
        ]
    }
    
}

