//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 01/10/23.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController:NSObject, UITableViewDataSource {
    
    private let model: ImageCommnetViewModel
    
    public init(model: ImageCommnetViewModel) {
        self.model = model
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.userName
        cell.dateLabel.text = model.date
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
    
}
