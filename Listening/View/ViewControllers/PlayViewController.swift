//
//  PlayViewController.swift
//  Listening
//
//  Created by huydoquang on 3/10/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class PlayViewController: BaseViewController {
    @IBOutlet weak var modeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UINavigationItem!
    @IBOutlet weak var paragraphTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fullControlView: LyricSettingFullControlView!
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!
    @IBOutlet var singleTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    
    var viewModel: PlayViewModelInterface!
    weak var delegate: LyricSettingViewControllerDelegate?
    private var loopView: LoopNotifyView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        self.tableView.estimatedRowHeight = 30.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let cellNib = UINib(nibName: String(describing: LyricTableViewCell.self), bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: Constants.TableViewCellIdentifier.lyricTableViewCell)
        self.fullControlView.delegate = self
        self.paragraphTextView.textColor = .orange
        self.singleTapGesture.require(toFail: self.doubleTapGesture)
    }
    
    private func setupData() {
        self.viewModel.didPlay.bind {[weak self] (didPlay) in
            self?.fullControlView.play()
        }
        
        self.viewModel.didStop.bind {[weak self] (didStop) in
            self?.fullControlView.stop()
        }
        
        self.viewModel.didMove.bind {[weak self] (time) in
            self?.fullControlView.updateCurrentTime(currentTime: time)
        }
        
        self.viewModel.didPause.bind {[weak self] (didPause) in
            self?.fullControlView.pause()
        }
        
        self.viewModel.didSeekToEnd.bind {[weak self] (didSeekToEnd) in
            self?.fullControlView.seekToEnd()
        }
        
        self.viewModel.didGetCurrentTime.bind {[weak self] (currentTime, percentage) in
            self?.fullControlView.updateCurrentTime(currentTime: currentTime, and: percentage)
        }
        
        self.viewModel.didGetDuration.bind {[weak self](duration) in
            self?.fullControlView.updateDuration(duration: duration)
        }
        
        self.viewModel.didParseLyric.bind {[weak self] (didParse) in
            self?.tableView.reloadData()
        }
        
        self.viewModel.didGetTitle.bind {[weak self] (title) in
            self?.navigationItem.title = title
        }
        
        self.viewModel.didChangeCurrentIndex.bind {[weak self] (indexPath, content) in
            self?.paragraphTextView.text = content
            self?.tableView.reloadRows(at: self?.tableView.indexPathsForVisibleRows ?? [], with: .automatic)
            self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        
        self.viewModel.didSetParagraphLoop.bind {[weak self] (content, hidden) in
            self?.changeLoop(content: content, hidden: hidden)
        }
        
        self.viewModel.didChangeMode.bind {[weak self] (mode) in
            self?.changedMode(mode: mode)
        }
        
        self.viewModel.didSetLoop.bind {[weak self] (loop) in
            self?.fullControlView.setup(loop: loop)
        }
        
        self.viewModel.setup()
    }
    
    private func changeLoop(content: String?, hidden: Bool) {
        if hidden {
            self.loopView?.dismiss(animated: true)
            self.loopView = nil
            self.textViewTopConstraint.constant = 0.0
            UIView.animate(withDuration: 0.25) {self.view.layoutIfNeeded()}
        } else if self.loopView == nil {
            let origin = self.tableView.frame.origin
            let size = CGSize(width: self.view.bounds.width, height: 30.0)
            let frame = CGRect(origin: origin, size: size)
            self.loopView = LoopNotifyView(frame: frame)
            self.textViewTopConstraint.constant = 30.0
            self.loopView?.show(on: self.view, animated: true, direction: .down)
            UIView.animate(withDuration: 0.25) {self.view.layoutIfNeeded()}
        }
        self.loopView?.setup(content: content)
    }
    
    private func changedMode(mode: LyricVisible) {
        switch mode {
        case .all:
            self.view.bringSubview(toFront: self.tableView)
            self.tableView.isHidden = false
            self.paragraphTextView.isHidden = true
            self.singleTapGesture.isEnabled = true
        case .current:
            self.view.bringSubview(toFront: self.paragraphTextView)
            self.tableView.isHidden = true
            self.paragraphTextView.isHidden = false
            self.singleTapGesture.isEnabled = false
        default:
            self.tableView.isHidden = true
            self.paragraphTextView.isHidden = true
            self.singleTapGesture.isEnabled = false
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.delegate?.dismiss()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        self.viewModel.changeMode()
    }
    
    @IBAction func processDoubleTapGesture(_ sender: UITapGestureRecognizer) {
        self.viewModel.setParagraphLoop()
    }
    
    @IBAction func processSingleTapGesture(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            self.viewModel.select(at: indexPath)
        }
    }
}

extension PlayViewController: LyricSettingFullControlViewDelegate {
    func didClickNextButton(button: UIButton) {
        self.viewModel.next()
    }
    
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
    
    func didClickLoopButton(button: UIButton) {
        self.viewModel.setLoop()
    }
}

extension PlayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRow(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifier.lyricTableViewCell, for: indexPath) as! LyricTableViewCell
        cell.setup(viewModel: self.viewModel.lyricTableViewCellModel(at: indexPath))
        return cell
    }
}

extension PlayViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let viewTouched = touch.view, !viewTouched.isDescendant(of: self.fullControlView) else {
            return false
        }
        return true
    }
}
