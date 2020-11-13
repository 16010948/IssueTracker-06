//
//  LabelViewController.swift
//  IssueTracker
//
//  Created by eunjeong lee on 2020/11/05.
//

import UIKit

protocol LabelViewControllerDelegate {
    func label(_ label: Label)
    func snapshot(_ snapshot: UIView)
}

class LabelViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var labelCollectionView: UICollectionView!
    private var selectedIndexPath: IndexPath?
    private var labels: Labels?
    
    private var selectedLabel: Label? {
        guard let indexPath = selectedIndexPath else { return nil }
        return labels?[indexPath.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeNavigationBarUnderLine()
        configureLabelListData() { [weak self] in
            self?.configureLabelCollectionView()
        }
    }
    
    private func configureLabelListData(completionHandler: (() -> Void)? = nil) {
        LabelListDataManager().get(successHandler: { [weak self] in
            self?.labels = $0
            completionHandler?()
        })
    }
    
    private func removeNavigationBarUnderLine() {
        navigationBar.shadowImage = UIImage()
    }
    
    private func registerNib() {
        let nib = UINib(nibName: Constant.labelCollectionViewCell, bundle: nil)
        labelCollectionView.register(nib, forCellWithReuseIdentifier: Constant.labelCell)
    }
    
    private func configureLabelCollectionView() {
        registerNib()
        labelCollectionView.delegate = self
        labelCollectionView.dataSource = self
    }
    
    private func configurePresentedViewController(_ viewController: LabelAddViewController) {
        viewController.updateLabelDelegate = self
        guard let snapshot = UIApplication.snapshotView else { return }
        viewController.snapshot(snapshot)
        guard let label = selectedLabel else { return }
        viewController.label(label)
        selectedIndexPath = nil
    }
    
    @IBSegueAction private func presentAddViewController(_ coder: NSCoder) -> LabelAddViewController? {
        let addViewController = LabelAddViewController(coder: coder)
        guard let viewController = addViewController else { return addViewController }
        configurePresentedViewController(viewController)
        return addViewController
    }
    
    @IBSegueAction private func presentUpdateViewController(_ coder: NSCoder) -> LabelAddViewController? {
        let updateViewController = LabelAddViewController(coder: coder)
        guard let viewController = updateViewController else { return updateViewController }
        configurePresentedViewController(viewController)
        return updateViewController
    }
}

extension LabelViewController: UpdateLabelDelegate {
    
    func add(label: Label) {
        labels?.add(label: label)
        labelCollectionView.reloadData()
    }
    
    func update(label: Label) {
        labels?.replace(label: label)
        labelCollectionView.reloadData()
    }
}

extension LabelViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: Constant.updateSegue, sender: nil)
    }
}

extension LabelViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        labels?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = labelCollectionView.dequeueReusableCell(
            withReuseIdentifier: Constant.labelCell,
            for: indexPath)
        
        guard let labelCell = cell as? LabelCollectionViewCell,
              let labels = labels,
              let label = labels[indexPath.row]
        else {
            return cell
        }
        labelCell.configureCell(with: label)
        return cell
    }
}

extension LabelViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: 100)
    }
}

private extension LabelViewController {
    
    enum Constant {
        static let updateSegue: String = "UpdateSegue"
        static let labelCell: String = "LabelCell"
        static let labelCollectionViewCell: String = "LabelCollectionViewCell"
        static let labelMilestoneAddViewController: String = "LabelMilestoneAddViewController"
    }
}

extension UIView {
   func snapshotImage() -> UIImage? {
       UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
       drawHierarchy(in: bounds, afterScreenUpdates: false)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return image
   }
}
