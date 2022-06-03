//
//  UIButton+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Prabhat Tiwari on 03/06/22.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
    
}
