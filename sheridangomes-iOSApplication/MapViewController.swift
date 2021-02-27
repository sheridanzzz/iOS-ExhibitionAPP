//
//  MapViewController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 10/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, DatabaseListener {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var imageName: String = ""
    var exName:String = ""
    var exDes: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var imageIcon: String = ""
    var allExhibitions: [Exhibition] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .all
    var exhibitionList = [LocationAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let latitude:CLLocationDegrees = -37.8304
        let longitude:CLLocationDegrees = 144.9796
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let zoomRegion = MKCoordinateRegion(center: location, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
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
    
    //adds annotations to the map view first
    private lazy var addAnno: Void = {
        for exhibition in allExhibitions {
            let location = LocationAnnotation(title: exhibition.name ?? "", subtitle: exhibition.exDescription ?? "", image: exhibition.icon ?? "", lat: exhibition.latitude, long: exhibition.longitude)
            exhibitionList.append(location)
        }
        
        for i in exhibitionList{
            mapView.addAnnotation(i)
        }
    }()
    
    lazy var removeAnno: Void = {
        print(exhibitionList.count)
        print("number")
        mapView.removeAnnotations(exhibitionList)
    }()
    
    // MARK: - Database Listener
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitions = exhibitions
        print (allExhibitions.count)
        _ = addAnno
    }
    
    func onPlantListChange(change: DatabaseChange, exhibitionPlants plants: [Plant]) {
        // Do nothing not called
    }
    
    //zoom in on the map
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    //too add annotation images
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        annotationView?.image = nil
        exName = ""
        exDes = ""
        lat = 0.0
        long = 0.0
        
        let cpa = annotation as! LocationAnnotation
        annotationView?.image = UIImage(named: cpa.image ?? "")
        annotationView?.canShowCallout = true
        annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    var loco : MKPointAnnotation!
    
    //send data to exhibition details view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ExhibitionDetailsViewController
        {
            let ed = segue.destination as? ExhibitionDetailsViewController
            ed?.name = exName
            ed?.des = exDes
            ed?.lat = lat
            ed?.long = long
            ed?.icon = imageIcon
            ed?.pin = loco
        }
    }
    
    //annotation call out to move to the next view
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            loco = view.annotation as? MKPointAnnotation
            exName = view.annotation!.title!!
            exDes = view.annotation!.subtitle!!
            lat = view.annotation!.coordinate.latitude
            long = view.annotation!.coordinate.longitude
            
            performSegue(withIdentifier: "exhibitionDetailsSegue", sender: self)
        }
    }
    
}

//References:
//call out: https://stackoverflow.com/questions/51091590/swift-storyboard-creating-a-segue-in-mapview-using-calloutaccessorycontroltapp

//How to pass map annotation on segue to mapView on another vc?:  https://stackoverflow.com/questions/44139763/how-to-pass-map-annotation-on-segue-to-mapview-on-another-vc

//Perform Segue from map annotation:  https://stackoverflow.com/questions/33053832/swift-perform-segue-from-map-annotation

