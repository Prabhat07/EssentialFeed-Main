//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 26/01/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
