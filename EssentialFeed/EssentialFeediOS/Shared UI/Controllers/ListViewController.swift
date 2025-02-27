//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Prabhat Tiwari on 29/09/21.
//

import UIKit
import EssentialFeed

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    
    public var onRefresh: (() -> ())?
    
    private(set) public var errorView = ErrorView()
    
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, index, cellController in
           return cellController.dataSource.tableView(tableView, cellForRowAt: index)
        }
    }()
    
    private var onViewAppearing: ((ListViewController) -> ())?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        configureErrorView()
        
        onViewAppearing = { vc in
            vc.onViewAppearing = nil
            vc.refresh()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearing?(self)
    }
    
    public override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexpath in
            let dsp = cellController(at: indexpath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexpath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    
}


