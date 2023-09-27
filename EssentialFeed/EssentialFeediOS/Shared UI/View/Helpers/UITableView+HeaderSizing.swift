//
//  UITableView+HeaderSizing.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 09/06/22.
//

import UIKit

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsFrameUpdates = header.frame.height != size.height
        if needsFrameUpdates {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
