//
//  ExhibitionDetailsViewController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 17/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ExhibitionDetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DatabaseListener {
    
    @IBOutlet weak var exDetailsName: UILabel!
    @IBOutlet weak var exDetailsDes: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var plantExCollectionView: UICollectionView!
    @IBOutlet weak var exNameField: UITextField!
    @IBOutlet weak var exDesField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var exSaveButton: UIButton!
    
    
    var name: String = ""
    var des: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var icon: String = ""
    var allPlants: [Plant] = []
    var allExhibitions: [Exhibition] = []
    var plantList: [Plant] = []
    var pin : MKPointAnnotation!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exDetailsName.text = "Exhibition Name:"
        exDetailsDes.text = "Description:"
        
        plantExCollectionView.delegate = self
        plantExCollectionView.dataSource = self
        plantExCollectionView.backgroundColor = .white
        
        mapView.delegate = self
        
        print(name)
        
        let latitude:CLLocationDegrees = lat
        let longitude:CLLocationDegrees = long
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let zoomRegion = MKCoordinateRegion(center: location, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Exhibition Location"
        annotation.subtitle = ""
        self.mapView.addAnnotation(annotation)
        
        exNameField.attributedPlaceholder = NSAttributedString(string: name,
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        exDesField.attributedPlaceholder = NSAttributedString(string: des,
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    //on button press show button and edit textbox
    @IBAction func editBtn(_ sender: Any) {
        exNameField.isEnabled = true
        exNameField.isUserInteractionEnabled = true
        
        exDesField.isEnabled = true
        exDesField.isUserInteractionEnabled = true
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true
        
        exDetailsName.text = "Exhibition Name (Edit Textbox):"
        exDetailsDes.text = "Description (Edit Textbox):"
        locationLabel.text = "Location (long tap to select or deselect):"
        
        exSaveButton.isHidden = false
    }
    
    @IBAction func saveDetailsBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        return
    }
    
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            lat = 0.0
            long = 0.0
            addAnnotation(location: locationOnMap)
        }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let allAnnotations = self.mapView.annotations
        if (allAnnotations.count > 0){
            self.mapView.removeAnnotations(allAnnotations)
        }else {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            lat = location.latitude
            long = location.longitude
            print(location)
            print (lat)
            print (long)
            annotation.title = "Your Location"
            annotation.subtitle = ""
            self.mapView.addAnnotation(annotation)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("plant count")
        print(allPlants.count)
        return allPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plantExCell", for: indexPath) as! PlantExhibitionDetailsCollectionViewCell
        let plant = allPlants[indexPath.row]
        //print (plant.plantExhibitions?.allObjects as Any)
        print ("ha")
        cell.plantExImageView.downloaded1(from: plant.image ?? "")
        cell.plantExNameLabel.text = plant.name
        return cell
    }
    
    //move to plant details view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "PlantDetailsViewController") as? PlantDetailsViewController
        let plant = allPlants[indexPath.row]
        vc?.name = plant.name ?? ""
        vc?.family = plant.family ?? ""
        vc?.imageUrl = plant.image ?? ""
        vc?.scientificName = plant.scientificName ?? ""
        vc?.year = String(plant.yearDiscovered)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Database Listener Functions
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitions = exhibitions
        
        for ex in exhibitions {
            if ex.name == name{
                print("lol")
                print(ex.exhibitionPlants?.allObjects as Any)
            }
        }
    }
    
    func onPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        allPlants = exhibitionPlants
        //fetchData()
        print("plant count")
        print(allPlants.count)
        plantExCollectionView.reloadData()
    }
    
    //    func fetchData() {
    //        do {
    //            let newExhibition = Exhibition(context: self.context)
    //            newExhibition.name = name
    //            newExhibition.exDescription = des
    //            newExhibition.latitude = lat
    //            newExhibition.longitude = long
    //            newExhibition.icon = ""
    //
    //
    //            print("plants jdnsjnfkewkfek")
    //            print()
    ////            self.plantList = try context.fetch(Plant.fetchRequest())
    ////            // find all Persons who have a nickname associated with that person
    ////            let predicate = NSPredicate(format: "ANY exhibitionPlants in %@", newExhibition)
    ////            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Plant")
    ////            fetch.predicate = predicate
    ////            let fetchError : NSError? = nil
    ////            print(fetchError as Any)
    ////            // executes fetch
    ////            let results = try context.execute(fetch)
    ////            print("List")
    ////            print(results)
    //        } catch {
    //        }
    //    }
    
}

extension UIImageView {
    func downloaded1(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                var image = UIImage(data: data)
                else { return }
            image = resize(image: image, newWidth: CGFloat())!
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                
            }
        }.resume()
    }
    func downloaded1(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

func resize(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

//References:
//placeholder color: https://stackoverflow.com/questions/33414757/how-to-change-uitextfield-placeholder-color-and-fontsize-using-swift-2-0
//resize: https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
