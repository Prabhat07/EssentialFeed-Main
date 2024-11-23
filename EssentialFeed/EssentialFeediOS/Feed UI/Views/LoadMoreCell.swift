//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 23/11/24.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 40),
            spinner.widthAnchor.constraint(equalToConstant: 40),
        ])
        return spinner
    }()
    
    public var isLoading: Bool {
        get {
            spinner.isAnimating
        }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
}
