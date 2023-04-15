//
//  LocalJsonDataSource.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

class LocalJsonDataSource : DataSource {
    
    var source : ContentSourceType = .networkLocation
    var weatherData: Weather?
    var locationsData : [String : [Location]] = [String : [Location]]()
    
    let defaultCountry = "US" // Could be populated using a configuration class
    
    func generateLocationData( city : String, state : String, completionHandler : @escaping ([Location]?, NSError?) -> Void ) {
        
        guard city != "" else {
            let error = NSError(domain: "MissingInfoErrorDomain", code: 101, userInfo: [NSLocalizedDescriptionKey: "Missing either city or state info in the search string"])
            completionHandler(nil, error)
            return
        }
        
        var searchTerm = city
        if state == "" {
            searchTerm += "," + defaultCountry
        } else {
            searchTerm += "," + state + "," + defaultCountry
        }
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        
        execQueue.async {
            let (locationsData, error) = Utilities.generateLocationDataFromBundleJSONFile(searchTerm: searchTerm, sourceFile: "locationsMock")
            completionHandler(locationsData, error)
        }
    }
    
    func generateLocationData( lat : Double, lon : Double, completionHandler : @escaping ([Location]?, NSError? ) -> Void) {
       
        print("Not supported yet!!")
        return
    }
    
    func generateWeatherData( currentLocationData : Location, completionHandler: @escaping (Weather?, NSError?) -> Void) {
        
        let execQueue = DispatchQueue.global(qos:.userInitiated)
        
        execQueue.async {
            let (weatherData, decodeError) = Utilities.generateWeatherDataFromBundleJSONFile(sourceFile: "weatherFremontMock")
            completionHandler(weatherData, decodeError)
        }
    }
}

