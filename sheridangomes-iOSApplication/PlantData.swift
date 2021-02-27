//
//  PlantData.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 14/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit

class PlantData: NSObject, Decodable {
    
    var name: String?
    var scientificName: String?
    var yearDiscovered: String?
    var image: String?
    var family: String?
    
    private enum RootKeys: String, CodingKey {
        case name = "common_name"
        case scientificName = "scientific_name"
        case yearDiscovered = "year"
        case image = "image_url"
        case family = "family_common_name"
    }
    
    private struct ImageURIs: Decodable {
        var png: String?
    }
    
    required init(from decoder: Decoder) throws {
        let plantContainer = try decoder.container(keyedBy: RootKeys.self)
        
        name = try plantContainer.decode(String.self, forKey: .name)
        scientificName = try plantContainer.decode(String.self, forKey: .scientificName)
        yearDiscovered = try? "\(plantContainer.decode(Int.self, forKey: .yearDiscovered))"
        family = try? plantContainer.decode(String.self, forKey: .family)
        image = try? plantContainer.decode(String.self, forKey: .image)
    }
}
