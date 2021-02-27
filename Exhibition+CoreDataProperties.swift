//
//  Exhibition+CoreDataProperties.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 11/09/20.
//  Copyright © 2020 monash. All rights reserved.
//
//

import Foundation
import CoreData


extension Exhibition {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exhibition> {
        return NSFetchRequest<Exhibition>(entityName: "Exhibition")
    }
    
    @NSManaged public var exDescription: String?
    @NSManaged public var icon: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var exhibitionPlants: NSSet?
    
    public var wrappedExname: String {
        name ?? "unkown"
    }
    
    //array of the plants that belong to exhibition
    public var plantArray: [Plant] {
        let set = exhibitionPlants as? Set<Plant> ?? []
        
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for exhibitionPlants
extension Exhibition {
    
    @objc(addExhibitionPlantsObject:)
    @NSManaged public func addToExhibitionPlants(_ value: Plant)
    
    @objc(removeExhibitionPlantsObject:)
    @NSManaged public func removeFromExhibitionPlants(_ value: Plant)
    
    @objc(addExhibitionPlants:)
    @NSManaged public func addToExhibitionPlants(_ values: NSSet)
    
    @objc(removeExhibitionPlants:)
    @NSManaged public func removeFromExhibitionPlants(_ values: NSSet)
    
}
