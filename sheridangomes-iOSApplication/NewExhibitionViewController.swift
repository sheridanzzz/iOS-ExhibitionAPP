//
//  NewLocationViewController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 10/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit
import MapKit
import CoreData

protocol NewExhibitionDelegate: NSObject {
    func locationAnnotationAdded(annotation: LocationAnnotation)
}

class NewExhibitionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DatabaseListener, PlantSendingDelegateProtocol{
    
    @IBOutlet weak var ExhibitionNameTextField: UITextField!
    @IBOutlet weak var DescriptionTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var iconCreImageView2: UIImageView!
    @IBOutlet weak var iconCreImageView1: UIImageView!
    @IBOutlet weak var iconCreImageView: UIImageView!
    @IBOutlet weak var plantCollection: UICollectionView!
    
    
    var lat = 0.0
    var long = 0.0
    var image = "tree"
    var image1 = "plant"
    var image2 = "flower"
    var chosenImage = ""
    var allPlants: [PlantData] = []
    var changePlants: [Plant] = []
    var plantList: [Plant] = []
    var exhibitionAdd: [Exhibition] = []
    var plantAdd: PlantData? = nil
    var plantDetails: Plant = Plant()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var delegate: NewExhibitionDelegate?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plantCollection.delegate = self
        plantCollection.dataSource = self
        plantCollection.backgroundColor = .white
        
        //code to know which icon is selected
        // create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewExhibitionViewController.imageTapped(gesture:)))
        
        // add it to the image view;
        iconCreImageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        iconCreImageView.isUserInteractionEnabled = true
        
        iconCreImageView.image =  UIImage(named: image )
        
        
        //second image
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(NewExhibitionViewController.imageTapped1(gesture:)))
        iconCreImageView1.addGestureRecognizer(tapGesture1)
        // make sure imageView can be interacted with by user
        iconCreImageView1.isUserInteractionEnabled = true
        
        iconCreImageView1.image =  UIImage(named: image1 )
        
        //third image
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(NewExhibitionViewController.imageTapped2(gesture:)))
        iconCreImageView2.addGestureRecognizer(tapGesture2)
        // make sure imageView can be interacted with by user
        iconCreImageView2.isUserInteractionEnabled = true
        
        iconCreImageView2.image =  UIImage(named: image2 )
        
        
        mapView.delegate = self
        
        let latitude:CLLocationDegrees = -37.8304
        let longitude:CLLocationDegrees = 144.9796
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let zoomRegion = MKCoordinateRegion(center: location, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        //for the location picked on the map view by the user
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        // Do any additional setup after loading the view.
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
    
    //recieve the plant data from the search plant view delegate
    func sendPlantData(myPlant: PlantData) {
        plantAdd = myPlant
        allPlants.append(plantAdd!)
        plantCollection.reloadData()
    }
    
    //prepare to segue to the search plant screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlantSegue" {
            let secondVC: SearchPlantsTableViewController = segue.destination as! SearchPlantsTableViewController
            secondVC.delegate = self
        }
    }
    
    //to know if image was tapped by the user
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            
            iconCreImageView.layer.masksToBounds = true
            iconCreImageView.layer.borderWidth = 1.5
            iconCreImageView.layer.borderColor = UIColor.blue.cgColor
            iconCreImageView.layer.cornerRadius = iconCreImageView.bounds.width / 2
            
            iconCreImageView1.layer.borderWidth = 0
            iconCreImageView2.layer.borderWidth = 0
            
            chosenImage = image
            
        }
    }
    
    @objc func imageTapped1(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped 1")
            
            iconCreImageView1.layer.masksToBounds = true
            iconCreImageView1.layer.borderWidth = 1.5
            iconCreImageView1.layer.borderColor = UIColor.blue.cgColor
            iconCreImageView1.layer.cornerRadius = iconCreImageView.bounds.width / 2
            
            iconCreImageView.layer.borderWidth = 0
            iconCreImageView2.layer.borderWidth = 0
            
            chosenImage = image1
            
        }
    }
    
    @objc func imageTapped2(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped 2")
            //Here you can initiate your new ViewController
            iconCreImageView2.layer.masksToBounds = true
            iconCreImageView2.layer.borderWidth = 1.5
            iconCreImageView2.layer.borderColor = UIColor.blue.cgColor
            iconCreImageView2.layer.cornerRadius = iconCreImageView.bounds.width / 2
            
            iconCreImageView.layer.borderWidth = 0
            iconCreImageView1.layer.borderWidth = 0
            
            chosenImage = image2
            
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plantListCell", for: indexPath) as! PlantCollectionViewCell
        let plant = allPlants[indexPath.row]
        //if no plant image, set this as image
        if plant.image == ""{
            plant.image = "notFound"
        }
        cell.plantImageView.downloadedFrom(from: plant.image ?? "")
        cell.plantLabel.text = plant.name
        return cell
    }
    
    // MARK: - Database Listener Functions
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // Do nothing not called
    }
    
    func onPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        //        allPlants = exhibitionPlants
        //        print("plant count")
        //        print(allPlants.count)
        plantCollection.reloadData()
    }
    
    // MARK: - addPlantExhibition Delegate
    func addPlantExhibition(newPlant: Plant, newExhibition: Exhibition) -> Bool {
        return databaseController!.addPlantToExhibition(plant: newPlant, exhibition: newExhibition)
    }
    
    func fetchData() {
        do {
            self.plantList = try context.fetch(Plant.fetchRequest())
            // find all Persons who have a nickname associated with that person
            let predicate = NSPredicate(format: "ANY plantExhibitions.name in %@", "")
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Plant")
            fetch.predicate = predicate
            let fetchError : NSError? = nil
            print(fetchError as Any)
            // executes fetch
            let results = try context.execute(fetch)
            print(results)
        } catch {
        }
    }
    
    
    @IBAction func createExhibition(_ sender: Any) {
        
        if ExhibitionNameTextField.text != "" && DescriptionTextField.text != "" && long != 0.0 && chosenImage != "" && allPlants.count >= 3{
            let name = ExhibitionNameTextField.text!
            let description = DescriptionTextField.text!
            let longi = long
            let lati = lat
            
            print("plants there")
            print(allPlants.count)
            
            
            
            let newExhibition = Exhibition(context: self.context)
            newExhibition.name = name
            newExhibition.exDescription = description
            newExhibition.longitude = longi
            newExhibition.latitude = lati
            newExhibition.icon = chosenImage
            
            // _ = (databaseController?.addExhibition(name: name, exDescription: description, latitude: lati, longitude: longi, icon: chosenImage))!
            
            //adds plants to exhibition
            for plant in allPlants{
                let newPlant = Plant(context: self.context)
                newPlant.name = plant.name
                newPlant.family = plant.family
                newPlant.image = plant.image
                newPlant.scientificName = plant.scientificName
                newPlant.yearDiscovered = Int32(plant.yearDiscovered ?? "") ?? 0
                newExhibition.addToExhibitionPlants(newPlant)
                //newExhibition.addToExhibitionPlants(Plant)
                //newPlant.addToPlantExhibitions(newExhibition)
                
                let _ =  databaseController!.addPlantToExhibition(plant: newPlant, exhibition: newExhibition)
                let _ = databaseController?.addSearchPlant(plantData: plant)
                
            }
            
            let _ = databaseController?.addExhibitionObj(exhibition: newExhibition)
            
            navigationController?.popViewController(animated: true)
            return
        }
        
        //validation for the fields
        var errorMsg = "Please ensure all fields are filled:\n"
        
        //add validation for 3 plants
        if ExhibitionNameTextField.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if DescriptionTextField.text == "" {
            errorMsg += "- Must provide description\n"
        }
        if long == 0.0 {
            errorMsg += "- Must provide location\n"
        }
        if chosenImage == "" {
            errorMsg += "- Please pick a icon\n"
        }
        if allPlants.count < 3 {
            errorMsg += "- Please add atleast three plants"
        }
        displayMessage(title: "Not all fields filled", msg: errorMsg)
    }
    //error message
    func displayMessage(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //to know where the user tapped on the map
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
    
    //add an annotation where the user tapped
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
}

func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
    
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        pinView!.pinTintColor = UIColor.black
    }
    else {
        pinView!.annotation = annotation
    }
    return pinView
}

func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print("tapped on pin ")
}

func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
        if (view.annotation?.title!) != nil {
        }
    }
}

//to get the image from url
extension UIImageView {
    func downloadedFrom(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                var image = UIImage(data: data)
                else { return }
            image = resizeImage(image: image, newWidth: CGFloat())!
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                
            }
        }.resume()
    }
    func downloadedFrom(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

//to resize the image
func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}


//References
//CollectionView tutorial: https://www.youtube.com/watch?v=k90V115zqRk&ab_channel=maxcodes, https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started
//Pass Data Between View Controllers: https://learnappmaking.com/pass-data-between-view-controllers-swift-how-to/

//delegate and protocol tutorial: https://medium.com/@astitv96/passing-data-between-view-controllers-using-delegate-and-protocol-ios-swift-4-beginners-e32828862d3f
//image tap: https://stackoverflow.com/questions/30958745/how-to-detect-which-image-has-been-tapped-in-swift

//long press map view: https://stackoverflow.com/questions/30858360/adding-a-pin-annotation-to-a-map-view-on-a-long-press-in-swift
