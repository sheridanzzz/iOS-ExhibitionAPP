//
//  DatabaseProtocol.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 11/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import Foundation

//Reference: Core data lab
enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    case exhibition
    case plants
    case all
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExhibitionChange(change: DatabaseChange, exhibitions : [Exhibition])
    func onPlantListChange(change: DatabaseChange, exhibitionPlants : [Plant])
}
protocol DatabaseProtocol: AnyObject {
    var defaultExhibition: Exhibition {get}
    func cleanup()
    func addSearchPlant(plantData: PlantData) -> Plant
    func addExhibitionObj(exhibition: Exhibition) -> Exhibition
    func addPlant(name: String, scientificName: String, family: String, yearDiscovered: integer_t, image: String) -> Plant
    func addExhibition(name: String, exDescription: String, latitude: Double, longitude: Double, icon: String) -> Exhibition
    func addPlantToExhibition(plant: Plant, exhibition: Exhibition) -> Bool
    func deletePlant(plant: Plant)
    func deleteExhibition(exhibition: Exhibition)
    func removePlantFromExhibition(plant: Plant, exhibition: Exhibition)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
