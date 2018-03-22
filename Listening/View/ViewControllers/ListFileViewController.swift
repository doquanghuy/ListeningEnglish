//
//  ListFileViewController.swift
//  Listening
//
//  Created by huydoquang on 3/2/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class ListFileViewController: BaseViewController {
    @IBOutlet weak var downloadTableView: UITableView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var viewModel: ListFileViewModelInterface = ListFileViewModel()
    
    class var instance: ListFileViewController {
        return UIStoryboard(name: Constants.Storyboards.main.name, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboards.main.viewControllers[self.name]!) as! ListFileViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        self.listTableView.register(LoadingFooterView.self, forHeaderFooterViewReuseIdentifier: Constants.TableViewCellIdentifier.loadingFooterView)
        
        self.view.bringSubview(toFront: listTableView)
    }

    private func setupData() {
        self.viewModel.loadData()
        
        self.viewModel.didLoadFoldersSelected.bind {[weak self] (didLoadFolder) in
            self?.listTableView.reloadData()
        }
        
        self.viewModel.didLoadFilesOfFoldersSelected.bind {[weak self] (section) in
            self?.listTableView.reloadSections([section], with: .automatic)
        }
        
        self.viewModel.didLoadMoreAtSection.bind {[weak self] (section) in
            self?.listTableView.reloadSections([section], with: .automatic)
        }
        
        self.viewModel.didSignOut.bind {[weak self] (didSignOut) in
            self?.signout()
        }
        
        self.viewModel.didDownloadFilesAtIndexPath.bind {[weak self] (indexPath) in
            self?.listTableView.reloadRows(at: [indexPath], with: .automatic)
            self?.viewModel.loadItemsDownloaded()
        }
        
        self.viewModel.didCancelDownloadFiles.bind {[weak self] (indexPath) in
            self?.listTableView.reloadRows(at: [indexPath], with: .automatic)
            self?.viewModel.loadItemsDownloaded()
        }
        
        self.viewModel.didLoadItemsDownloaded.bind {[weak self] (didLoad) in
            self?.downloadTableView.reloadData()
        }
        
        self.viewModel.didRemoveItemDownloaded.bind {[weak self] (indexPath) in
            self?.downloadTableView.deleteRows(at: [indexPath], with: .fade)
            self?.listTableView.reloadData()
        }
        
        self.viewModel.loadItemsDownloaded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.fromListFileVCToLyricSetting {
            guard let navVC = segue.destination as? UINavigationController, let lyricSettingVC = navVC.topViewController as? LyricSettingViewController, let indexPath = sender as? IndexPath, let viewModel = self.viewModel.lyricSettingViewModel(at: indexPath) else {return}
            lyricSettingVC.viewModel = viewModel
            lyricSettingVC.delegate = self
        } else if segue.identifier == Constants.Segue.fromListFileVCToPlayVC {
            guard let navVC = segue.destination as? UINavigationController, let playVC = navVC.topViewController as? PlayViewController, let indexPath = sender as? IndexPath, let viewModel = self.viewModel.playViewModel(at: indexPath) else {return}
            playVC.viewModel = viewModel
            playVC.delegate = self
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        self.viewModel.signout()
    }
    
    @IBAction func changeSegmentedControlValue(_ segmentControl: UISegmentedControl) {
        let tableView = [listTableView, downloadTableView][segmentControl.selectedSegmentIndex]!
        self.view.bringSubview(toFront: tableView)
        if tableView == downloadTableView {
            self.viewModel.loadItemsDownloaded()
        }
    }
}

extension ListFileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == listTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            self.viewModel.selectItem(at: indexPath)
        } else {
            let identifier = !self.viewModel.jsonFileExisted(at: indexPath, at: tableView.tag) ? Constants.Segue.fromListFileVCToLyricSetting : Constants.Segue.fromListFileVCToPlayVC
            self.performSegue(withIdentifier: identifier, sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == listTableView {
            guard let cellViewModel = self.viewModel.listFileCellModel(at: indexPath, at: tableView.tag) as? ListFileCellModelInterface else {return}
            (cell as? ListItemTableViewCell)?.setup(viewModel: cellViewModel)
        } else {
            guard let cellViewModel = self.viewModel.listFileCellModel(at: indexPath, at: tableView.tag) as? ListItemDownloadedTableViewCellModelInterface else {return}
            (cell as? ListItemDownloadedTableViewCell)?.setup(viewModel: cellViewModel)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.TableViewCellIdentifier.loadingFooterView) as? LoadingFooterView
        let cellViewModel = self.viewModel.loadingFooterViewModel(at: section)
        footerView?.setup(section: section, delegate: self, viewModel: cellViewModel)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == listTableView ? 44.0 : 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView == listTableView ? 44.0 : 0.0
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard tableView == downloadTableView else {return .none}
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard tableView == downloadTableView else {return}
        self.viewModel.removeItemDownloaded(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard tableView == downloadTableView else {return nil}
        var actions = [UITableViewRowAction]()
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") {[weak self] (action, indexPath) in
            self?.viewModel.removeItemDownloaded(at: indexPath)
        }
        actions.append(deleteAction)
        
        if self.viewModel.jsonFileExisted(at: indexPath, at: tableView.tag) {
            let editJSON = UITableViewRowAction(style: .normal, title: "Edit", handler: {[weak self] (action, indexPath) in
                self?.performSegue(withIdentifier: Constants.Segue.fromListFileVCToLyricSetting, sender: indexPath)
            })
            actions.append(editJSON)
        }
        
        return actions
    }
}

extension ListFileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
       return self.viewModel.numberOfSection(at: tableView.tag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowIn(section: section, at: tableView.tag)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == listTableView {
            return tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifier.listItemTableViewCell, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifier.listItemDownloadedTableViewCell, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.title(for: section, at: tableView.tag)
    }
}

extension ListFileViewController: LoadingFooterViewDelegate {
    func loading(loadingFooterView: LoadingFooterView, section: Int) {
        self.viewModel.loadMore(at: section)
    }
}

extension ListFileViewController: LyricSettingViewControllerDelegate {
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
