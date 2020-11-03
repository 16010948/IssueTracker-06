//
//  IssueListCollectionViewDataSource.swift
//  IssueTracker
//
//  Created by eunjeong lee on 2020/11/02.
//

import UIKit

final class IssueListCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    private let collectionView: UICollectionView
    private let data: [Issue]
    private let scrollEnabled: Bool
    private let checkboxEnabled: Bool
    
    init(
        collectionView: UICollectionView,
        data: [Issue],
        scrollEnabled: Bool = true,
        checkboxEnabled: Bool = false) {
        self.collectionView = collectionView
        self.data = data
        self.scrollEnabled = scrollEnabled
        self.checkboxEnabled = checkboxEnabled
        super.init()
        self.registerNib()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constant.issueListCell,
            for: indexPath
        )
        if let issueListCollectionViewCell = cell as? IssueListCollectionViewCell {
            configureIssueListCollectionViewCellWidth(issueListCollectionViewCell)
            configureIssueListCollectionViewCellData(issueListCollectionViewCell, at: indexPath)
            configureCellLayout(issueListCollectionViewCell)
        }
        return cell
    }
    
    private func registerNib() {
        let nib = UINib(nibName: Constant.issueListCollectionViewCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: Constant.issueListCell)
    }
    
    private func configureIssueListCollectionViewCellWidth(_ cell: IssueListCollectionViewCell) {
        let cellwidth: CGFloat = collectionView.bounds.width + Metric.closeButtonWidth + Metric.deleteButtonWidth
        cell.setWidth(cellwidth)
    }

    private func configureIssueListCollectionViewCellData(
        _ cell: IssueListCollectionViewCell,
        at indexPath: IndexPath) {
        let issue = MockupData.data[indexPath.row]
        cell.setIssue(issue)
    }
    
    private func configureCellLayout(_ cell: IssueListCollectionViewCell) {
        if !scrollEnabled {
            cell.disableScroll()
        }
        if !checkboxEnabled {
            cell.disableCheckbox()
        }
    }
}

private extension IssueListCollectionViewDataSource {
    enum Constant {
        static let issueListCell: String = "IssueListCell"
        static let issueListCollectionViewCell: String = "IssueListCollectionViewCell"
    }
    
    enum Metric {
        static let cellHeight: CGFloat = 100
        static let closeButtonWidth: CGFloat = 80
        static let deleteButtonWidth: CGFloat = 80
    }
}
