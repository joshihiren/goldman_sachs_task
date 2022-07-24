//
//  NasaDetailCell.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import UIKit
import AVFoundation

class NasaDetailCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    
    @IBOutlet weak var mainview: UIView!
    
    @IBOutlet weak var typeloaderview: UIView!
    @IBOutlet weak var thumnilIMG: UIImageView!
    
    @IBOutlet weak var favBTN: UIButton!
    @IBOutlet weak var expandBTN: UIButton!
    
    @IBOutlet weak var infoview: UIView!
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var noteslbl: UILabel!
    
    var expandblock: (() -> ())?
    
    var nasaobj: PlanetryApodModel!
    var playerController: ASVideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.expandBTN.isHidden = true
        self.mainview.clipsToBounds = true
        self.mainview.layer.cornerRadius = 20
        self.thumnilIMG.backgroundColor = .gray
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        thumnilIMG.layer.addSublayer(videoLayer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        thumnilIMG.imageURL = nil
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let horizontalMargin: CGFloat = 20
        let width: CGFloat = bounds.size.width - horizontalMargin * 2
        let height: CGFloat = (width * 0.9).rounded(.up)
        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(thumnilIMG.frame, from: thumnilIMG)
        guard let videoFrame = videoFrameInParentSuperView,
              let superViewFrame = superview?.frame else {
            return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
    
    public func configure(with obj: PlanetryApodModel) {
        self.nasaobj = obj
        if obj.media_type?.uppercased() == "image".uppercased() {
            self.expandBTN.isHidden = true
            self.thumnilIMG.imageURL = obj.hdurl
        }
        else {
            self.expandBTN.isHidden = false
            self.thumnilIMG.imageURL = obj.url
            self.videoURL = obj.hdurl
        }
        
        if (obj.fav_Status == "1") {
            self.favBTN.setImage(UIImage.init(named: "FavIC"), for: .normal)
            self.favBTN.isSelected = true
        }
        else {
            self.favBTN.setImage(UIImage.init(named: "UnfavIC"), for: .normal)
            self.favBTN.isSelected = false
        }
        self.titlelbl.text = obj.title!
        self.datelbl.text = obj.date!
        self.noteslbl.text = obj.explanation!
    }
    
    @IBAction func TappedFav(_ sender: UIButton) {
        if self.favBTN.isSelected {
            let updateqry = updateStatment.init()
            updateqry.table(Kpods_Table)
            updateqry.column(Kfav_Status, value: "0")
            updateqry.where(Ktitle, operator: "=", value: self.nasaobj.title)
            let status = DBManager.shared().executeQuery(updateqry.statement())
            if status == true {
                self.favBTN.setImage(UIImage.init(named: "UnfavIC"), for: .normal)
                self.favBTN.isSelected = false
            }
        }
        else {
            let updateqry = updateStatment.init()
            updateqry.table(Kpods_Table)
            updateqry.column(Kfav_Status, value: "1")
            updateqry.where(Ktitle, operator: "=", value: self.nasaobj.title)
            let status = DBManager.shared().executeQuery(updateqry.statement())
            if status == true {
                self.favBTN.setImage(UIImage.init(named: "FavIC"), for: .normal)
                self.favBTN.isSelected = true
            }
        }
    }
    
    @IBAction func tappedexpandBTN(_ sender: UIButton) {
        if self.expandblock != nil {
            self.expandblock?()
        }
    }
    
}
