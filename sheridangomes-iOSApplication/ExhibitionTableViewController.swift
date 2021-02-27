//
//  LocationTableViewController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 10/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit
import MapKit


class ExhibitionTableViewController: UITableViewController, NewExhibitionDelegate, UISearchResultsUpdating, DatabaseListener, CLLocationManagerDelegate {
    
    @IBOutlet weak var sortbutton: UIBarButtonItem!

    let CELL_EXHIBITION = "exhibitionCell"
    var allExhibitions: [Exhibition] = []
    var filteredExhibitions: [Exhibition] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .all
    var isSorted = false
    
    //reference to mapViewController
    weak var mapViewController: MapViewController?
    var exhibitionList = [LocationAnnotation]()
    var geofence: CLCircularRegion?
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredExhibitions = allExhibitions
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibitions"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
    }
    
    //listeners on view appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
    }
    
    //listeners on view disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    //to sort the exhibition list A-Z or Z-A
    //References: all images from https://icons8.com/
    // sort tutorial: https://www.hackingwithswift.com/example-code/arrays/how-to-sort-an-array-using-sort
    @IBAction func sortList(_ sender: Any) {
        if isSorted == false{
            sortbutton.image = UIImage(named: "icons8-ascending-sorting-50")
            filteredExhibitions.sort { $0.name!.lowercased() < $1.name!.lowercased() }
            tableView.reloadData()
            isSorted = true
        }else {
            sortbutton.image = UIImage(named: "icons8-descending-sorting-50")
            filteredExhibitions.sort { $0.name!.lowercased() > $1.name!.lowercased() }
            tableView.reloadData()
            isSorted = false
        }
    }
    
    // MARK: - Geofencing Methods
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message:
            "You have left exhibition", preferredStyle:
            UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Search Controller Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        print(searchText)
        if searchText.count > 0 {
            filteredExhibitions = allExhibitions.filter({ (exhibition: Exhibition) -> Bool in
                guard let name = exhibition.name else {
                    return false
                }
                return name.contains(searchText)
            })
        } else {
            filteredExhibitions = allExhibitions
        }
        tableView.reloadData()
    }
    // MARK: - Database Listener
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitions = exhibitions
        exhibitionList.removeAll()
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onPlantListChange(change: DatabaseChange, exhibitionPlants plants: [Plant]) {
        // Do nothing not called
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredExhibitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exhibitionCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXHIBITION,
                                                           for: indexPath) as! ExhibitionTableViewCell
        let exhibition = filteredExhibitions[indexPath.row]
        exhibitionCell.nameLabel.text = exhibition.name
        exhibitionCell.descriptionLabel.text = exhibition.exDescription
        exhibitionCell.iconImageView.image =  UIImage(named: exhibition.icon ?? "")
        
        let location = LocationAnnotation(title: exhibition.name ?? "", subtitle: exhibition.exDescription ?? "", image: exhibition.icon ?? "", lat: exhibition.latitude, long: exhibition.longitude)
        mapViewController?.mapView.addAnnotation(location)
        exhibitionList.append(location)
        return exhibitionCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let exhibition1 = filteredExhibitions[indexPath.row]
            let annotation = exhibitionList[indexPath.row]
            exhibitionList.remove(at: indexPath.row)
            filteredExhibitions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let _ = databaseController?.deleteExhibition(exhibition: exhibition1)
            mapViewController?.mapView.removeAnnotation(annotation)
            return
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        _ = mapViewController?.removeAnno
        mapViewController?.focusOn(annotation: self.exhibitionList[indexPath.row])
        geofence = CLCircularRegion(center: exhibitionList[indexPath.row].coordinate, radius: 500,
                                    identifier: "geofence")
        geofence?.notifyOnExit = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: geofence!)
        
        if let mapVC = mapViewController {
            splitViewController?.showDetailViewController(mapVC, sender: nil)
        }
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExhibitionSegue" {
            let controller = segue.destination as! NewExhibitionViewController
            controller.delegate = self
        }
    }
    // MARK: - New Location Delegate
    func locationAnnotationAdded(annotation: LocationAnnotation) {
        exhibitionList.append(annotation)
        tableView.insertRows(at: [IndexPath(row: exhibitionList.count - 1,
                                            section: 0)], with: .automatic)
        mapViewController?.mapView.addAnnotation(annotation)
    }
}

//get the images from a url
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

//References:

//Pass data from tableView Cell to another view controller: https://www.youtube.com/watch?v=hGV9pfssmXA&ab_channel=LetCreateAnApp, https://stackoverflow.com/questions/26981887/tableview-pushing-to-detail-view-in-swift

