//
//  VolumeData.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 14/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit

class VolumeData: NSObject, Decodable {
    
    var total_plants: Int?
    var has_more: Bool?
    var plants: [PlantData]?
    
    private enum CodingKeys: String, CodingKey {
        case total_plants
        case has_more
        case plants = "data"
    }
}
