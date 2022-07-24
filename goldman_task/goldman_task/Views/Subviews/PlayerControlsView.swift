//
//  PlayerControlsView.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import UIKit
import AVFoundation

enum PlayerControl: Int, CaseIterable {
    case skipBack
    case scanBack
    case play
    case pause
    case scanForward
    case skipForward
    
    var image: UIImage? {
        switch self {
        case .skipBack:
            return UIImage(named: "skip15sec_back")
        case .scanBack:
            return UIImage(named: "scanBackward")
        case .play:
            return UIImage(named: "play-icon")
        case .pause:
            return UIImage(named: "pause-icon")
        case .scanForward:
            return UIImage(named: "scanForward")
        case .skipForward:
            return UIImage(named: "skip15sec_forward")
        }
    }
}

enum PlayerControlsViewOutCmd {
    case playerControlDidPress(PlayerControl)
    case sliderDidMove(CMTime)
    case sliderDidBegan(Bool)
}

typealias PlayerControlsViewOut = (PlayerControlsViewOutCmd) -> ()

final class PlayerControlsView: UIView {
    
    // MARK: - Private var
    
    private var playerControls: [PlayerControl] = [.skipBack,
                                                   .scanBack,
                                                   .play,
                                                   .scanForward,
                                                   .skipForward]
    private var playPauseButton: UIButton!
    
    // Subviews
    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var timelineSlider: UISlider = {
        var slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(timeSliderDidChange(_:event:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var timelineCurrentPositionLabel: UILabel = {
        var l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12, weight: .light)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()
    
    private lazy var timelineDurationLabel: UILabel = {
        var l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12, weight: .light)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.spacing = 15
        v.axis = .horizontal
        return v
    }()
    
    // MARK: - Public var
    
    public var out: PlayerControlsViewOut?
    public var isPlaying: Bool = false {
        didSet {
            let playButtonImage = isPlaying ? PlayerControl.pause.image : PlayerControl.play.image
            playPauseButton.setImage(playButtonImage, for: .normal)
        }
    }
    
    // MARK: - Private func
    
    private func setupUI() {
        addSubview(containerView)
        addSubview(timelineCurrentPositionLabel)
        addSubview(timelineSlider)
        addSubview(timelineDurationLabel)
        addSubview(buttonsStackView)
        
        clipsToBounds = true
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            timelineCurrentPositionLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 5),
            timelineCurrentPositionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            timelineCurrentPositionLabel.bottomAnchor.constraint(lessThanOrEqualTo: buttonsStackView.topAnchor,
                                                                 constant: 0),
            timelineCurrentPositionLabel.trailingAnchor.constraint(equalTo: timelineSlider.leadingAnchor, constant: -5),
            timelineCurrentPositionLabel.centerYAnchor.constraint(equalTo: timelineSlider.centerYAnchor),
            
            timelineSlider.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            timelineSlider.heightAnchor.constraint(equalToConstant: 20),
            
            timelineDurationLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 5),
            timelineDurationLabel.leadingAnchor.constraint(equalTo: timelineSlider.trailingAnchor, constant: 5),
            timelineDurationLabel.bottomAnchor.constraint(lessThanOrEqualTo: buttonsStackView.topAnchor,
                                                          constant: 0),
            timelineDurationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            timelineDurationLabel.centerYAnchor.constraint(equalTo: timelineSlider.centerYAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: timelineSlider.bottomAnchor, constant: 5),
            buttonsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonsStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupStackView() {
        playerControls.forEach {
            let button = UIButton.systemButton(with: $0.image!,
                                               target: self,
                                               action: #selector(controlButtonDidPress(_:)))
            if $0 == .play {
                playPauseButton = button
            }
            button.setImage($0.image, for: .normal)
            button.tag = $0.rawValue
            buttonsStackView.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 50),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    // MARK: - Actions
    
    @objc private func controlButtonDidPress(_ button: UIButton) {
        let playerControl = PlayerControl(rawValue: button.tag)!
        out?(.playerControlDidPress(playerControl))
    }
    
    @objc private func timeSliderDidChange(_ sender: UISlider, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        
        switch touch.phase {
        case .began:
            out?(.sliderDidBegan(true))
        case .moved:
            let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            out?(.sliderDidMove(newTime))
        case .ended:
            out?(.sliderDidBegan(false))
        default: break
        }
    }
    
    // MARK: - Public func
    
    public func setTimeSlider(value: Float) {
        timelineSlider.setValue(value, animated: true)
    }
    
    public func setTimeSlider(currentPosition: Float) {
        timelineCurrentPositionLabel.text = TimeFormatter.formateSecondsToMS(currentPosition)
    }
    
    public func setTimeSlider(duration: Float) {
        timelineSlider.maximumValue = duration
        timelineDurationLabel.text = TimeFormatter.formateSecondsToMS(duration)
    }
    
    public func setControls(enabled: Bool) {
        timelineSlider.isEnabled = enabled
        buttonsStackView.subviews.forEach {
            let button = $0 as! UIButton
            button.isEnabled = enabled
        }
    }
    
    // MARK: - Life cycle
    
    init() {
        super.init(frame: .zero)
        
        setupUI()
        setupLayout()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
