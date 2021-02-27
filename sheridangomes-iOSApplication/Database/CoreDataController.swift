//
//  CoreDataController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 11/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit
import CoreData

//Reference: Core data lab
class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    
    // Fetched Results Controllers
    var allPlantsFetchedResultsController: NSFetchedResultsController<Plant>?
    var ExhibitonPlantsFetchedResultsController: NSFetchedResultsController<Exhibition>?
    
    override init() {
        // Load the Core Data Stack
        persistentContainer = NSPersistentContainer(name: "iOSApplication-Model")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        super.init()
        if fetchExhibitionPlants().count == 0 {
            createDefaultEntries()
        }
    }
    
    // MARK: - Lazy Initization
    lazy var defaultExhibition: Exhibition = {
        var exhibitions = [Exhibition]()
        return exhibitions.first!
    }()
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save to CoreData: \(error)")
            }
        }
    }
    
    // MARK: - Database Protocol Functions
    func cleanup() {
        saveContext()
    }
    
    //add plant data from the search view
    func addSearchPlant(plantData: PlantData) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant",
                                                        into: persistentContainer.viewContext) as! Plant
        plant.name = plantData.name
        plant.family = plantData.family
        plant.image = plantData.image
        plant.scientificName = plantData.scientificName
        plant.yearDiscovered = Int32(plantData.yearDiscovered!)!
        return plant
    }
    
    func addExhibitionObj(exhibition: Exhibition) -> Exhibition {
        let exhibition1 = NSEntityDescription.insertNewObject(forEntityName: "Exhibition",
                                                              into: persistentContainer.viewContext) as! Exhibition
        exhibition1.name = exhibition.name
        exhibition1.exDescription = exhibition.exDescription
        exhibition1.latitude = exhibition.latitude
        exhibition1.longitude = exhibition.longitude
        exhibition1.icon = exhibition.icon
        
        try! persistentContainer.viewContext.save()
        
        return exhibition
    }
    
    //add plant to core data
    func addPlant(name: String, scientificName: String, family: String, yearDiscovered: integer_t, image: String) -> Plant {
        let plant = NSEntityDescription.insertNewObject(forEntityName: "Plant",
                                                        into: persistentContainer.viewContext) as! Plant
        plant.name = name
        plant.scientificName = scientificName
        plant.family = family
        plant.yearDiscovered = yearDiscovered
        plant.image = image
        
        return plant
    }
    
    //add exhibition to core data
    func addExhibition(name: String, exDescription: String, latitude: Double, longitude: Double, icon: String) -> Exhibition {
        let exhibition = NSEntityDescription.insertNewObject(forEntityName: "Exhibition",
                                                             into: persistentContainer.viewContext) as! Exhibition
        exhibition.name = name
        exhibition.exDescription = exDescription
        exhibition.latitude = latitude
        exhibition.longitude = longitude
        exhibition.icon = icon
        
        try! persistentContainer.viewContext.save()
        
        return exhibition
    }
    
    //add plant to exhibition
    func addPlantToExhibition(plant: Plant, exhibition: Exhibition) -> Bool {
        exhibition.addToExhibitionPlants(plant)
        return true
    }
    
    func deletePlant(plant: Plant) {
        persistentContainer.viewContext.delete(plant)
    }
    
    func deleteExhibition(exhibition: Exhibition) {
        persistentContainer.viewContext.delete(exhibition)
        try! persistentContainer.viewContext.save()
    }
    
    func removePlantFromExhibition(plant: Plant, exhibition: Exhibition) {
        exhibition.removeFromExhibitionPlants(plant)
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .exhibition || listener.listenerType == .all {
            listener.onExhibitionChange(change: .update, exhibitions: fetchExhibitionPlants())
        }
        
        if listener.listenerType == .plants || listener.listenerType == .all {
            listener.onPlantListChange(change: .update, exhibitionPlants: fetchAllPlants())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK: - Fetched Results Controller Protocol Functions
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allPlantsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .plants || listener.listenerType == .all {
                    listener.onPlantListChange(change: .update, exhibitionPlants: fetchAllPlants())
                }
            }
        } else if controller == ExhibitonPlantsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .exhibition || listener.listenerType == .all {
                    listener.onExhibitionChange(change: .update, exhibitions: fetchExhibitionPlants())
                }
            }
        }
    }
    
    // MARK: - Core Data Fetch Requests
    func fetchAllPlants() -> [Plant] {
        // If results controller not currently initialized
        if allPlantsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            // Sort by name
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            // Initialize Results Controller
            allPlantsFetchedResultsController =
                NSFetchedResultsController<Plant>(fetchRequest:
                    fetchRequest, managedObjectContext: persistentContainer.viewContext,
                                  sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allPlantsFetchedResultsController?.delegate = self
            
            do {
                try allPlantsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var plants = [Plant]()
        if allPlantsFetchedResultsController?.fetchedObjects != nil {
            plants = (allPlantsFetchedResultsController?.fetchedObjects)!
        }
        
        return plants
    }
    
    
    func fetchExhibitionPlants() -> [Exhibition] {
        if ExhibitonPlantsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exhibition> = Exhibition.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            ExhibitonPlantsFetchedResultsController = NSFetchedResultsController<Exhibition>(fetchRequest: fetchRequest,
                                                                                             managedObjectContext: persistentContainer.viewContext,
                                                                                             sectionNameKeyPath: nil, cacheName: nil)
            ExhibitonPlantsFetchedResultsController?.delegate = self
            
            do {
                try ExhibitonPlantsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        var plants = [Exhibition]()
        if ExhibitonPlantsFetchedResultsController?.fetchedObjects != nil {
            plants = (ExhibitonPlantsFetchedResultsController?.fetchedObjects)!
        }
        
        return plants
    }
    
    // MARK: - Default Entry Generation
    //default exhibitions
    func createDefaultEntries() {
        let _ = addExhibition(name: "Grey Garden", exDescription: "Collection of silver leaved plants", latitude: -37.8304, longitude: 144.9796, icon: "plant")
        let _ = addExhibition(name: "Camellia Collection", exDescription: "world-acclaimed Camellia Collection", latitude: -37.82813602352844, longitude: 144.9789857789762, icon: "flower")
        let _ = addExhibition(name: "Oak Collection", exDescription: "Oaks from around the world", latitude: -37.83114549665294, longitude: 144.9820616131233, icon: "tree")
        let _ = addExhibition(name: "Bamboo Collection", exDescription: "Evolutionary collection", latitude: -37.82905877641291, longitude: 144.9839119371227, icon: "plant")
        let _ = addExhibition(name: "Rose Collection", exDescription: "collection of old fashioned roses", latitude: -37.83216699375738, longitude: 144.9821660989595, icon: "flower")
        
        let _ = addPlant(name: "Bush grass", scientificName: "Calamagrostis epigejos", family: "Grass family", yearDiscovered: 1788, image: "https://bs.floristic.org/image/o/fb6a942f5095a43cdf80c5902f7f76552309a3e3")
        let _ = addPlant(name: "double coconut", scientificName: "Lodoicea maldivica", family: "Palm family", yearDiscovered: 1807, image: "https://bs.floristic.org/image/o/1ad4853b6c359bac439ef21a714a9b5568c91b63")
        let _ = addPlant(name: "field rose", scientificName: "Rosa arvensis", family: "Rose family", yearDiscovered: 1762, image: "https://bs.floristic.org/image/o/afc9f4d7ce137f04746413f629330948b73e79d3")
        
        try! persistentContainer.viewContext.save()
    }
}
