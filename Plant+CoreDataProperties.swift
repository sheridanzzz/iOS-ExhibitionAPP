//
//  Plant+CoreDataProperties.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 11/09/20.
//  Copyright © 2020 monash. All rights reserved.
//
//

import Foundation
import CoreData


extension Plant {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }
    
    @NSManaged public var family: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var yearDiscovered: Int32
    @NSManaged public var plantExhibitions: NSSet?
    
    //get the name of the plant
    public var wrappedName: String {
        name ?? "unkown"
    }
}

// MARK: Generated accessors for plantExhibitions
extension Plant {
    
    @objc(addPlantExhibitionsObject:)
    @NSManaged public func addToPlantExhibitions(_ value: Exhibition)
    
    @objc(removePlantExhibitionsObject:)
    @NSManaged public func removeFromPlantExhibitions(_ value: Exhibition)
    
    @objc(addPlantExhibitions:)
    @NSManaged public func addToPlantExhibitions(_ values: NSSet)
    
    @objc(removePlantExhibitions:)
    @NSManaged public func removeFromPlantExhibitions(_ values: NSSet)
    
}
