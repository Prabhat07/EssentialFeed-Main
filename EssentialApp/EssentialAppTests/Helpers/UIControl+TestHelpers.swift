//
//  UIControl+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
