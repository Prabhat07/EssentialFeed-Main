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
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        contentView.addSubview(label)
        label.textColor = .tertiaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
        ])
        return label
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
    
    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue}
    }
    
}
