//
//  LyricSettingViewController.swift
//  Listening
//
//  Created by huydoquang on 3/4/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

protocol LyricSettingViewControllerDelegate: class {
    func dismiss()
}

class LyricSettingViewController: UIViewController {
    @IBOutlet weak var lyricSettingControlView: LyricSettingControlView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: LyricSettingViewModelInterface!
    weak var delegate: LyricSettingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupData()
    }
    
    private func setupUI() {
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let cellNib = UINib(nibName: String(describing: LyricTableViewCell.self), bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: Constants.TableViewCellIdentifier.lyricTableViewCell)
        self.lyricSettingControlView.delegate = self
    }
    
    private func setupData() {
        self.viewModel.didPlay.bind {[weak self] (didPlay) in
            self?.tableView.reloadData()
            self?.lyricSettingControlView.play()
        }
        
        self.viewModel.didStop.bind {[weak self] (didStop) in
            self?.lyricSettingControlView.stop()
        }
        
        self.viewModel.didMove.bind {[weak self] (time) in
            self?.lyricSettingControlView.updateCurrentTime(currentTime: time)
        }
        
        self.viewModel.didPause.bind {[weak self] (didPause) in
            self?.tableView.reloadData()
            self?.lyricSettingControlView.pause()
        }
        
        self.viewModel.didSeekToEnd.bind {[weak self] (didSeekToEnd) in
            self?.lyricSettingControlView.seekToEnd()
        }
        
        self.viewModel.didGetCurrentTime.bind {[weak self] (currentTime, percentage) in
            self?.lyricSettingControlView.updateCurrentTime(currentTime: currentTime, and: percentage)
        }
        
        self.viewModel.didGetDuration.bind {[weak self](duration) in
            self?.lyricSettingControlView.updateDuration(duration: duration)
        }
        
        self.viewModel.didParseLyric.bind {[weak self] (didParse) in
            self?.tableView.reloadData()
        }
        
        self.viewModel.didSelect.bind {[weak self] (indexPath) in
            self?.tableView.reloadData()
        }
        
        self.viewModel.didBack.bind {[weak self] (didBack) in
            self?.tableView.reloadData()
        }
        
        self.viewModel.didEndMove.bind {[weak self] (time) in
            self?.tableView.reloadData()
        }
        
        self.viewModel.didSave.bind {[weak self] (didSave) in
            guard didSave else {return}
            self?.performSegue(withIdentifier: Constants.Segue.fromLyricSettingVCToPlayVC, sender: nil)
        }
        
        self.viewModel.setup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.Segue.fromLyricSettingVCToPlayVC else {return}
        let playVC = segue.destination as? PlayViewController
        playVC?.viewModel = self.viewModel.playViewModel
        playVC?.delegate = delegate
    }
        
    @IBAction func cancel(_ sender: Any) {
        self.delegate?.dismiss()
    }
    
    @IBAction func save(_ sender: Any) {
        self.viewModel.save()
    }
    
    deinit {
        print("Deinit")
    }
}

extension LyricSettingViewController: LyricSettingControlViewDelegate {
    func didClickBackButton(button: UIButton) {
        self.viewModel.back()
    }
        
    func didClickPlayButton(playButton: UIButton) {
        self.viewModel.playOrPause()
    }
    
    func didBeginTouchSlider(slider: UISlider) {
        self.viewModel.pause()
    }
    
    func didChangeValueSlider(slider: UISlider) {
        self.viewModel.move(to: slider.value)
    }
    
    func didEndChangeValudeSlider(slider: UISlider) {
        self.viewModel.endMove(to: slider.value)
    }
}

extension LyricSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.select(at: indexPath)
    }
}

extension LyricSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRow(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifier.lyricTableViewCell, for: indexPath) as! LyricTableViewCell
        cell.setup(viewModel: self.viewModel.lyricTableViewCellModel(at: indexPath))
        return cell
    }
}
