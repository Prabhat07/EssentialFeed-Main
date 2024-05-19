//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 01/04/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
