//
//  AVPlayerLayerViewController.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import UIKit
import AVFoundation
import AVKit

final class AVPlayerLayerViewController: UIViewController {
    
    // MARK: - Private var
    
    var player: AVPlayer!
    
    var videoURL: String?
    
    private var timeObserverToken: Any?
    private var playerTimeControlStatusObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    private var isSliderMoving = false
    
    private lazy var playerView: PlayerView = {
        let v = PlayerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .lightGray
        return v
    }()
    
    private lazy var playerControlsView: PlayerControlsView = {
        let v = PlayerControlsView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 15
        v.out = { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .playerControlDidPress(let playerControl):
                switch playerControl {
                case .skipBack:
                    self.skipBackward()
                case .scanBack:
                    self.playBackwards()
                case .play, .pause:
                    self.playVideo()
                case .scanForward:
                    self.playFastForward()
                case .skipForward:
                    self.skipForward()
                }
            case .sliderDidMove(let time):
                self.player.seek(to: time)
            case .sliderDidBegan(let isBegan):
                if isBegan {
                    self.isSliderMoving = true
                    self.player.pause()
                } else {
                    self.isSliderMoving = false
                    self.player.play()
                }
            }
        }
        return v
    }()
    
    // MARK: - Public var
    
    // MARK: - Private func
    
    private func setupUI() {
        view.addSubview(playerView)
        view.addSubview(playerControlsView)
        
        title = "AVPlayerLayer"
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            playerView.heightAnchor.constraint(equalToConstant: self.view.frame.height - 200),
            
            playerControlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            playerControlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            playerControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
//            playerControlsView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: URL.init(string: self.videoURL!)!)
        playerView.player = player
        setupPlayerObservers()
    }
    
    private func playVideo() {
        switch player.timeControlStatus {
        case .playing:
            player.pause()
        case .paused:
            let currentItem = player.currentItem
            if currentItem?.currentTime() == currentItem?.duration {
                currentItem?.seek(to: .zero, completionHandler: nil)
            }
            
            player.play()
        default:
            player.pause()
        }
    }
    
    func updatePlayPauseButtonImage() {
        switch player.timeControlStatus {
        case .playing:
            playerControlsView.isPlaying = true
        default:
            playerControlsView.isPlaying = false
        }
    }
    
    private func setupPlayerObservers() {
        // Create a periodic observer to update the movie player time slider during playback.
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval,
                                                           queue: .main) { [unowned self] time in
            let timeElapsed = Float(time.seconds)
            if !isSliderMoving {
                self.playerControlsView.setTimeSlider(value: timeElapsed)
            }
            self.playerControlsView.setTimeSlider(currentPosition: timeElapsed)
        }
        
        // Create an observer to toggle the play/pause button control icon
        // to reflect the playback state of the player's `timeControStatus` property.
        playerTimeControlStatusObserver = player.observe(\AVPlayer.timeControlStatus,
                                                          options: [.initial, .new]) { [unowned self] _, _ in
            DispatchQueue.main.async {
                self.updatePlayPauseButtonImage()
            }
        }
        
        // Create an observer on the player item `status` property to observe state changes as they occur.
        playerItemStatusObserver = player.observe(\AVPlayer.currentItem?.status,
                                                   options: [.new, .initial]) { [unowned self] _, _ in
            DispatchQueue.main.async {
                // Configure the user interface elements for playback when
                // the player item's `status` changes to `readyToPlay`.
                self.updateUIforPlayerItemStatus()
            }
        }
    }
    
    private func skipForward() {
        let time = CMTime(seconds: CMTimeGetSeconds(self.player.currentTime()) + 15,
                          preferredTimescale: 1)
        self.player.seek(to: time, completionHandler: { _ in })
    }
    
    private func skipBackward() {
        let time = CMTime(seconds: CMTimeGetSeconds(self.player.currentTime()) - 15,
                          preferredTimescale: 1)
        self.player.seek(to: time, completionHandler: { _ in })
    }
    
    private func playFastForward() {
        if player.currentItem?.currentTime() == player.currentItem?.duration {
            player.currentItem?.seek(to: .zero, completionHandler: { _ in })
        }
        
        // Play fast forward no faster than 2.0.
        player.rate = min(player.rate + 2.0, 2.0)
    }
    
    private func playBackwards() {
        if player.currentItem?.currentTime() == .zero {
            if let duration = player.currentItem?.duration {
                player.currentItem?.seek(to: duration, completionHandler: { _ in })
            }
        }
        
        // Reverse no faster than -2.0.
        player.rate = max(player.rate - 2.0, -2.0)
    }
    
    private func updateUIforPlayerItemStatus() {
        guard let currentItem = player.currentItem else { return }
        
        switch currentItem.status {
        case .failed:
            playerControlsView.setControls(enabled: false)
            break
            
        case .readyToPlay:
            playerControlsView.setControls(enabled: true)
            
            // Update the time slider control, start time and duration labels for the player duration.
            let duration = Float(currentItem.duration.seconds)
            let currentPosition = Float(CMTimeGetSeconds(player.currentTime()))
            playerControlsView.setTimeSlider(currentPosition: currentPosition)
            playerControlsView.setTimeSlider(duration: duration)
            
        default:
            playerControlsView.setControls(enabled: false)
            break
        }
    }
    
    // MARK: - Public func
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.init(named: "BackgroundColor")
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        player.pause()
    }
    
}
