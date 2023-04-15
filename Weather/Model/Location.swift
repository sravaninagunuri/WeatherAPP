//
//  Location.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

struct Location : Decodable {
    let name : String
    let latitude : Double
    let longitude : Double
    let country : String
    let state : String
    
    enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "lon"
        case country
        case state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        self.latitude = Double(round(100 * latitude) / 100)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.longitude = Double(round(100 * longitude) / 100)
        self.country = try container.decode(String.self, forKey: .country)
        self.state = try container.decode(String.self, forKey: .state)
    }
}
