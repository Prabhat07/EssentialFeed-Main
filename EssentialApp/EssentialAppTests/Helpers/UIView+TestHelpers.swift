//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 10/06/22.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
