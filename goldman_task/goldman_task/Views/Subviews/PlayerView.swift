//
//  PlayerView.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import UIKit
import AVFoundation

final class PlayerView: UIView {
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
