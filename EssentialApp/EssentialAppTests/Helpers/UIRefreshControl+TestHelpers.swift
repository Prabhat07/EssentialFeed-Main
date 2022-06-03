//
//  UIRefreshControl+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import UIKit

extension UIRefreshControl {
    
    func simulatePullToResfresh() {
        simulate(event: .valueChanged)
    }
    
}
