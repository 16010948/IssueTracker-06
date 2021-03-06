//
//  ViewController.swift
//  IssueTracker
//
//  Created by 박태희 on 2020/10/27.
//

import UIKit

protocol IssueListViewControllerDelegate: class {
    func issueId(_ id: Int)
}

// 필터 화면 선택 추가
protocol IssuesFilterDelegate {
    func issues(_ issues: Issues)
}

final class IssueListViewController: UIViewController {

    @IBOutlet private weak var issueListCollectionView: UICollectionView!
    @IBOutlet private weak var leftBarButton: UIBarButtonItem!
    @IBOutlet private weak var rightBarButton: UIBarButtonItem!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addIssueButton: UIButton!
    @IBOutlet private weak var bottomToolbar: UIToolbar!
    @IBOutlet private weak var bottomGuidelineConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchBar: UISearchBar!

    private let issueListDataManager = IssueListDataManager()
    private var selectedIndexPath: IndexPath?
    
    var filterIssues: Issues = Issues() {
        didSet {
            issueListCollectionViewSetting?.update(issues: filterIssues)
        }
    }
    
    private var issues: Issues? {
        didSet {
            guard let issues = issues else { return }
            issueListCollectionViewSetting?.update(issues: issues)
        }
    }
    private var selectedIssues = Issues() {
        didSet {
            issueListCollectionViewSetting?.update(selectedIssues: selectedIssues)
        }
    }
  
    private var mode: IssueListCellMode = .normal {
        didSet {
            let isEditMode = mode.isEditMode
            changeMode(isEditMode: isEditMode)
        }
    }
        
    private lazy var issueListCollectionViewSetting: IssueListCollectionViewSetting? = {
        guard let issues = issues else { return nil }
        let issueListCollectionViewSetting = IssueListCollectionViewSetting(
            collectionView: issueListCollectionView,
            data: issues)
        
        issueListCollectionViewSetting.closeButtonHandler = closeButtonTouched(cell:)
        issueListCollectionViewSetting.deleteButtonHandler = deleteButtonTouched(cell:)
        return issueListCollectionViewSetting
    }()
    
    private lazy var normalModeTapGesture: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTouched(_:)))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.isEnabled = true
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }()
    
    private lazy var editModeTapGesture: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editCellTouched(_:)))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.isEnabled = false
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }()
    
    private lazy var keyboardHide: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.isEnabled = true
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureLeftBarButton()
        configureIssuesData() { [weak self] in
            self?.configureIssueListCollectionView()
        }
        configureBottomGuideline()
        removeNavigationBarUnderLine()
        normalModeTapGesture.delegate = self
        searchBar.delegate = self
    }
    
    private func changeMode(isEditMode: Bool) {
        selectedIssues = Issues()
        tabBarController?.tabBar.isHidden = isEditMode
        issueListCollectionViewSetting?.cellMode = mode
        bottomToolbar.isHidden = !isEditMode
        normalModeTapGesture.isEnabled = !isEditMode
        editModeTapGesture.isEnabled = isEditMode
        addIssueButton.isHidden = isEditMode
        let rightBarButtonTitle = isEditMode ? Constant.cancel : Constant.edit
        let leftBarButtonTitle = isEditMode ? Constant.selectAll : Constant.filter
        let leftBarButtonAction =
            isEditMode ? #selector(selectAllButtonTouched(_:)) : #selector(filterButtonTouched(_:))
        rightBarButton.title = rightBarButtonTitle
        leftBarButton.title = leftBarButtonTitle
        leftBarButton.action = leftBarButtonAction
        
        let titleText = isEditMode ? "\(selectedIssues.count.selectedCountText)" : Constant.issue
        titleLabel.text = titleText
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction private func rightBarButtonTouched(_ sender: UIBarButtonItem) {
        mode = mode.switchMode
    }
    
    @IBSegueAction private func presentIssueDeatilViewController(_ coder: NSCoder) -> IssueDetailViewController? {
        let issueDetailViewController = IssueDetailViewController(coder: coder)
        guard let selectedIndexPath = selectedIndexPath,
              let issueId = issues?[selectedIndexPath.row]?.id
        else {
            return issueDetailViewController
        }
        issueDetailViewController?.issueId(issueId)
        return issueDetailViewController
    }
    
    // 필터 화면 선택 추가
    @IBSegueAction private func presentFilterSelectViewController(_ coder: NSCoder) -> FilterSelectViewController? {
        let filterSelectViewController = FilterSelectViewController(coder: coder)
        guard let issues = issues else {
            return filterSelectViewController
        }
        filterSelectViewController?.issues(issues)
        return filterSelectViewController
    }
}

extension IssueListViewController: UISearchBarDelegate {
    // 서치바에 입력될때마다 호출되는 메소드
    // 이슈 데이터들 필터
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let issues = issues else { return }
        filterIssues = searchText.isEmpty ? issues : issues.filter {
            return $0.title.contains(searchText)
        }
    }
}

extension IssueListViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isUIControl = touch.view is UIControl
        return !isUIControl
    }
}

// MARK: NormalMode
private extension IssueListViewController {
    
    func moveToIssueFilterViewController() {
        view.endEditing(true)
        performSegue(withIdentifier: Constant.filterSegue, sender: nil)
    }
    
    func moveToIssueDetailViewController() {
        view.endEditing(true)
        performSegue(withIdentifier: Constant.issueDetailSegue, sender: nil)
    }
    
    func closeButtonTouched(cell: UICollectionViewCell) {
        guard let indexPath = issueListCollectionView.indexPath(for: cell),
              let issueID = issues?[indexPath.row]?.id else { return }
        issueListDataManager.closeIssue(id: issueID, successHandler: {
            DispatchQueue.main.async { [weak self] in
                self?.closeItemFromCollectionView(at: indexPath, id: issueID)
            }
        })
    }
    
    func closeItemFromCollectionView(at indexPath: IndexPath, id: Int) {
        issueListCollectionView.performBatchUpdates({
            issues?.close(id: [id])
            issueListCollectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    func deleteButtonTouched(cell: UICollectionViewCell) {
        guard let indexPath = issueListCollectionView.indexPath(for: cell),
              let issueID = issues?[indexPath.row]?.id else { return }
        issueListDataManager.delete(id: issueID, successHandler: {
            DispatchQueue.main.async { [weak self] in
                self?.presentDeleteIssueAlert(at: indexPath, id: issueID)
            }
        })
    }
    
    func presentDeleteIssueAlert(at indexPath: IndexPath, id: Int) {
        presentAlert(title: Constant.blank, message: Message.deleteIssue) { [weak self] in
            self?.deleteItemFromCollectionView(at: indexPath, id: id)
        }
    }
    
    func deleteItemFromCollectionView(at indexPath: IndexPath, id: Int) {
        issueListCollectionView.performBatchUpdates({
            issues?.remove(id: id)
            issueListCollectionView.deleteItems(at: [indexPath])
        }, completion: nil)
    }
    
    @objc func cellTouched(_ sender: UITapGestureRecognizer) {
        guard let indexPath = issueListCollectionView.indexPath(with: sender)
        else {
            return
        }
        selectedIndexPath = indexPath
        moveToIssueDetailViewController()
    }

    @objc func filterButtonTouched(_ sender: UIBarButtonItem) {
        moveToIssueFilterViewController()
    }
}

// MARK: EditMode
private extension IssueListViewController {
    
    func switchIssueSelected(issue: Issue) {
        if selectedIssues.contains(issue: issue) {
            selectedIssues.remove(issue: issue)
            return
        }
        selectedIssues.add(issue: issue)
    }
    
    @objc func editCellTouched(_ sender: UITapGestureRecognizer) {
        guard let indexPath = issueListCollectionView.indexPath(with: sender),
              let issue = issues?[indexPath.row]
        else { return }
        switchIssueSelected(issue: issue)
        titleLabel.text = selectedIssues.count.selectedCountText
    }
    
    @objc func selectAllButtonTouched(_ sender: UIBarButtonItem) {
        guard let issues = issues else { return }
        selectedIssues = issues
        titleLabel.text = selectedIssues.count.selectedCountText
    }

    @IBAction func selectedIssuesCloseButton(_ sender: UIBarButtonItem) {
        issueListDataManager.closeIssues(
            id: selectedIssues.id,
            successHandler: { id in
            DispatchQueue.main.async { [weak self] in
                self?.issues?.close(id: id)
                self?.mode = .normal
            }
        })
    }
}
  
// MARK: configure
private extension IssueListViewController {
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshIssues), for: .valueChanged)
        issueListCollectionView.refreshControl = refreshControl
    }
    
    @objc func refreshIssues(_ refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            refresh.endRefreshing()
        })
        configureIssuesData() {
            refresh.endRefreshing()
        }
    }
    
    func configureLeftBarButton() {
        leftBarButton.target = self
        leftBarButton.action = #selector(filterButtonTouched(_:))
    }
    
    func configureIssuesData(completionHandler: (() -> Void)? = nil) {
        issueListDataManager.get(successHandler: { [weak self] in
            self?.issues = $0
            completionHandler?()
        })
    }

    func configureIssueListCollectionView() {
        issueListCollectionView.delegate = issueListCollectionViewSetting
        issueListCollectionView.dataSource = issueListCollectionViewSetting
        issueListCollectionView.addGestureRecognizer(normalModeTapGesture)
        issueListCollectionView.addGestureRecognizer(editModeTapGesture)
        view.addGestureRecognizer(keyboardHide)
    }
    
    func configureBottomGuideline() {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        bottomGuidelineConstraint.constant = tabBarHeight
    }
    
    func removeNavigationBarUnderLine() {
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

private extension IssueListViewController {
    
    enum Constant {
        static let blank: String = ""
        static let filterSegue: String = "FilterSegue"
        static let issueDetailSegue: String = "IssueDetailSegue"
        static let issue: String = "이슈"
        static let cancel: String = "Cancel"
        static let edit: String = "Edit"
        static let selectAll: String = "SelectAll"
        static let filter: String = "Filter"
        static let 확인: String = "확인"
        static let 취소: String = "취소"
    }
    
    enum Message {
        static let deleteIssue: String = "이슈를 삭제하시겠습니까?\n삭제하면 다시 복구할 수 없습니다."
    }
}

private extension Int {
    
    var selectedCountText: String {
        "\(self)개 선택"
    }
}
