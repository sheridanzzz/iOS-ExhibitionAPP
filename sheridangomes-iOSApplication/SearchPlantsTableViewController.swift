//
//  SearchPlantsTableViewController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 14/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit

//to send plant data to the create exhibition view
protocol PlantSendingDelegateProtocol {
    func sendPlantData(myPlant: PlantData)
}

class SearchPlantsTableViewController: UITableViewController,  UISearchBarDelegate, DatabaseListener{
    
    let CELL_PLANT = "plantCell"
    //api url
    let REQUEST_STRING = "https://trefle.io/api/v1/plants/search?token=gJaR8Ab-DOge-vLLuN8zsyrhpyQu9kMFsAR9h1ioz9Q&q="
    
    let MAX_REQUESTS = 10
    
    var check: Bool = false
    
    var currentRequestPage: Int = 1
    //token
    let token = "gJaR8Ab-DOge-vLLuN8zsyrhpyQu9kMFsAR9h1ioz9Q"
    
    var indicator = UIActivityIndicatorView()
    var newPlants = [PlantData]()
    weak var databaseController: DatabaseProtocol?
    var delegate: PlantSendingDelegateProtocol? = nil
    var listenerType: ListenerType = .all
    var allPlants: [Plant] = []
    var filteredPlants: [Plant] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Plants"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newPlants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_PLANT,
                                                 for: indexPath)
        
        print(filteredPlants.count)
        //        if filteredPlants.count > 0 {
        //        let plant = filteredPlants[indexPath.row]
        //            cell.textLabel?.text = plant.name
        //            cell.detailTextLabel?.text = plant.family
        //        } else {
        let plant = newPlants[indexPath.row]
        
        cell.textLabel?.text = plant.name
        cell.detailTextLabel?.text = plant.family
        //}
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath) {
        let plant = newPlants[indexPath.row]
        let _ = databaseController?.addSearchPlant(plantData: plant)
        if self.delegate != nil {
            self.delegate?.sendPlantData(myPlant: plant)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // If there is no text end immediately
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return;
        }
        //checks if the plant is in the DB
        //        filteredPlants = allPlants.filter({ (plant: Plant) -> Bool in
        //            guard let name = plant.name else {
        //                return false
        //            }
        //            return name.contains(searchText)
        //        })
        
        //if no plant in DB search the api
        //if filteredPlants.count == 0 {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        
        newPlants.removeAll()
        tableView.reloadData()
        
        URLSession.shared.invalidateAndCancel()
        currentRequestPage = 1;
        
        requestPlants(plantName: searchText)
        // }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Database Listener
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        //nothing
    }
    
    func onPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        allPlants = exhibitionPlants
        print(allPlants)
    }
    
    // MARK: - Web Request
    //Api call
    //Reference: web service lab
    func requestPlants(plantName: String) {
        check = false
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "trefle.io"
        searchURLComponents.path = "/api/v1/plants/search"
        searchURLComponents.queryItems = [
            //
            URLQueryItem(name: "token", value: "\(token)"),
            URLQueryItem(name: "page", value: "\(currentRequestPage)"),
            URLQueryItem(name: "q", value: plantName)
        ]
        let jsonURL = URLRequest(url: searchURLComponents.url!)
        //print (jsonURL)
        let task = URLSession.shared.dataTask(with: jsonURL) {
            (data, response, error) in
            // Regardless of response end the loading icon from the main thread
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data!)
                if let plants = volumeData.plants {
                    self.check = true
                    self.newPlants.append(contentsOf: plants)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch let err {
                print(err)
            }
            DispatchQueue.main.async {
                self.noResults()
            }
        }
        
        task.resume()
        
    }
    
    //if no results display message
    func noResults(){
        if check == false {
            displayMessage(title: "No results found", msg: "Try Again!")
        }
    }
    
    func displayMessage(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
