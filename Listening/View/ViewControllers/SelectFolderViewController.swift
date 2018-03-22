//
//  ChooseFolderViewController.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll

class SelectFolderViewController: BaseViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedTableView: UITableView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!

    private let viewModel: SelectFolderViewModelInterface = SelectFolderViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    private func setupUI() {
        self.listTableView.keyboardDismissMode = .onDrag
        self.searchBar.becomeFirstResponder()
        
        self.listTableView.addInfiniteScroll {[weak self] (tableView) in
            self?.viewModel.beginLoadingResults(searchText: self?.searchBar.text ?? "", isLoadMore: true)
            self?.listTableView.finishInfiniteScroll()
        }
    }
    
    private func setupViewModel() {
        self.viewModel.didLoadingResults.bind(listener: {[weak self] (error, folders) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self?.listTableView.reloadData()
        })
        
        self.viewModel.didLoadSelectedFolders.bind {[weak self] (folders) in
            self?.saveBarButtonItem.isEnabled = !folders.isEmpty
        }
        
        self.viewModel.didResetResults.bind(listener: {[weak self] (didReset) in
            self?.listTableView.reloadData()
        })
        
        self.viewModel.didSelectFolder.bind(listener: {[weak self] (indexPath) in
            self?.listTableView.reloadRows(at: [indexPath], with: .automatic)
        })
        
        self.viewModel.didDeselectFolder.bind {[weak self] (indexPath) in
            self?.listTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        self.viewModel.didResetFolder.bind(listener: {[weak self] (indexPath) in
            self?.listTableView.reloadRows(at: [indexPath], with: .automatic)
        })
        
        self.viewModel.didSave.bind {[weak self] (didSave) in
            self?.searchBar.endEditing(true)
            self?.performSegue(withIdentifier: Constants.Segue.fromSelectFolderVCToListFileVC, sender: nil)
        }
        
        self.viewModel.didResetAll.bind {[weak self] (didResetAll) in
            self?.listTableView.reloadData()
        }
        
        self.viewModel.didSignOut.bind {[weak self] (didSignOut) in
            self?.signout()
        }
        
        self.viewModel.loadSelectedFolders()
    }
    
    @objc fileprivate func searchFolders(searchText: String) {
        viewModel.beginLoadingResults(searchText: searchText, isLoadMore: false)
    }
    
    @IBAction func save(_ sender: Any) {
        self.viewModel.save()
    }
    
    @IBAction func reset(_ sender: Any) {
        self.viewModel.resetSelectedAll()
    }
    
    @IBAction func signout(_ sender: Any) {
        self.viewModel.signOut()
    }
    
    @IBAction func changeSegmentedControl(_ segmentedControl: UISegmentedControl) {
        let tableView = [listTableView, selectedTableView][segmentedControl.selectedSegmentIndex]!
        self.view.bringSubview(toFront: tableView)
        self.searchBar.endEditing(true)
        self.searchBar.isUserInteractionEnabled = segmentedControl.selectedSegmentIndex == SelectFolderTableViewType.all.hashValue
        tableView.reloadData()
    }
}

extension SelectFolderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == listTableView else {return}
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectFolder(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard tableView == selectedTableView else {return .none}
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard tableView == selectedTableView else {return}
        self.viewModel.deSelectFolder(at: indexPath)
        self.selectedTableView.deleteRows(at: [indexPath], with: .fade)
    }
}

extension SelectFolderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRow(section: section, at: tableView.tag)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifier.listFolderTableViewCell, for: indexPath) as! ListFolderTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ListFolderTableViewCell, let cellViewModel = viewModel.listItemCellModel(at: indexPath, at: tableView.tag) else {return}
        cell.setup(viewModel: cellViewModel)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension SelectFolderViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.resetResults()
        self.searchBar.text = nil
        self.searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchFolders(searchText:)), object: searchBar)
        self.perform(#selector(self.searchFolders(searchText:)), with: searchText, afterDelay: 0.5)
    }
}
