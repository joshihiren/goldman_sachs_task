//
//  ViewController.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var nasaOBJ: [PlanetryApodModel?] = []
    var filterOBJ: [PlanetryApodModel?] = []
    private lazy var avPlayerLayerVC = AVPlayerLayerViewController()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pausePlayeVideos()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NASA Apod Data"
        self.tableView.register(UINib(nibName: "NasaDetailCell", bundle: nil), forCellReuseIdentifier: "NasaDetailCell")
        
        self.searchbar.delegate = self
        self.getofflinedata()
        
        // View load API call and add those records to the local database as well. Even while inserting into the database cross-check that data would not be duplicated as well.
        ApiManager.sharedInstance.doGet_nasa_details(param: [:]) { responseObjects, error in
            
            let selectqry = selectStatment.init()
            selectqry.from(Kpods_Table)
            selectqry.where(Ktitle, operator: "=", value: responseObjects?.title)
            let historyArray = DBManager.shared().loadData(fromDB: selectqry.statement())! as NSArray
            if historyArray.count == 0 {
                let insertqry = insertStatment.init()
                insertqry.into(Kpods_Table)
                insertqry.column(Kcopyright, value: responseObjects?.copyright)
                insertqry.column(Kdate, value: responseObjects?.date)
                insertqry.column(Kexplanation, value: responseObjects?.explanation)
                insertqry.column(Khdurl, value: responseObjects?.hdurl)
                insertqry.column(Kmedia_type, value: responseObjects?.media_type)
                insertqry.column(Kservice_version, value: responseObjects?.service_version)
                insertqry.column(Ktitle, value: responseObjects?.title)
                insertqry.column(Kurl, value: responseObjects?.url)
                insertqry.column(Kfav_Status, value: 0)
                let status = DBManager.shared().executeQuery(insertqry.statement())
                if status == true {
                    print("Reading data Insert successfully")
                }
                else
                {
                    self.nasaOBJ.append(responseObjects)
                    print("Reading data not inserted")
                }
            }
            else {
                let updateqry = updateStatment.init()
                updateqry.table(Kpods_Table)
                updateqry.column(Kcopyright, value: responseObjects?.copyright)
                updateqry.column(Kdate, value: responseObjects?.date)
                updateqry.column(Kexplanation, value: responseObjects?.explanation)
                updateqry.column(Khdurl, value: responseObjects?.hdurl)
                updateqry.column(Kmedia_type, value: responseObjects?.media_type)
                updateqry.column(Kservice_version, value: responseObjects?.service_version)
                updateqry.column(Ktitle, value: responseObjects?.title)
                updateqry.column(Kurl, value: responseObjects?.url)
                updateqry.where(Ktitle, operator: "=", value: responseObjects?.title)
                let status = DBManager.shared().executeQuery(updateqry.statement())
                if status == true {
                    print("update successfully")
                }
                else
                {
                    self.nasaOBJ.append(responseObjects)
                    print("Records not updated")
                }
            }
            // Get the data from the local database.
            self.getofflinedata()
        }
        // Notification for the user while app will go into backgound mode
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appEnteredFromBackground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // If the video is playing or running then manage pause and play here.
        pausePlayeVideos()
    }
    
    func getofflinedata() {
        self.nasaOBJ.removeAll()
        let selectqry = selectStatment.init()
        selectqry.from(Kpods_Table)
        let historyArray = DBManager.shared().loadData(fromDB: selectqry.statement())! as NSArray
        for item in historyArray {
            let dict: NSDictionary = item as! NSDictionary
            let obj = PlanetryApodModel.init(fromDictionary: dict as! [String : Any])
            self.nasaOBJ.append(obj)
        }
        self.filterOBJ = self.nasaOBJ
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource
// The methods adopted by the object you use to manage data and provide cells for a table view.
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterOBJ.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NasaDetailCell") as! NasaDetailCell
        cell.configure(with: self.filterOBJ[indexPath.row]!)
        
        // if the media type is video then given one option the expand the video screen with full screen.
        cell.expandblock = {
            ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
            let data = self.filterOBJ[indexPath.row]
            self.avPlayerLayerVC.videoURL = data?.hdurl
            self.navigationController?.pushViewController(self.avPlayerLayerVC, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // if the data objects is video type then while during active cell manage play option here.
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
    
    func pausePlayeVideos(){
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
    }
    
    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchbar.showsCancelButton = true
        return true
    }
    // Manage the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.filterOBJ.removeAll()
        let selectqry = selectStatment.init()
        selectqry.from(Kpods_Table)
        selectqry.where(Kdate, operator: "LIKE", value: self.searchbar.text!)
        let historyArray = DBManager.shared().loadData(fromDB: selectqry.statement())! as NSArray
        for item in historyArray {
            let dict: NSDictionary = item as! NSDictionary
            let obj = PlanetryApodModel.init(fromDictionary: dict as! [String : Any])
            // if there is no data related to search then it will be auto refresh with all data.
            if obj.date?.count == 0 {
                self.filterOBJ = self.nasaOBJ
            }
            else {
                self.filterOBJ.append(obj)
            }
        }
        self.tableView.reloadData()
        self.searchbar.showsCancelButton = false
        self.searchbar.text = ""
        self.searchbar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.showsCancelButton = false
        self.searchbar.text = ""
        self.searchbar.resignFirstResponder()
        self.getofflinedata()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.filterOBJ.removeAll()
        let selectqry = selectStatment.init()
        selectqry.from(Kpods_Table)
        selectqry.where(Kdate, operator: "LIKE", value: text)
        let historyArray = DBManager.shared().loadData(fromDB: selectqry.statement())! as NSArray
        for item in historyArray {
            let dict: NSDictionary = item as! NSDictionary
            let obj = PlanetryApodModel.init(fromDictionary: dict as! [String : Any])
            self.filterOBJ.append(obj)
        }
        self.tableView.reloadData()
        return true
    }
}
