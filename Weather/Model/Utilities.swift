//
//  Utilities.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

class Utilities {
    
    // Utility method for retrieving data from app bundle resource.
    // returns boolean indicating success/Failure retrieving the data
    static public func generateLocationDataFromBundleJSONFile( searchTerm : String, sourceFile : String ) -> ([Location]?, NSError?) {
        
        var locationsData : [Location]? = nil
        var error : NSError? = nil
        
        if let url = Bundle.main.url(forResource: sourceFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                locationsData =  try decoder.decode([Location].self, from: data)

            } catch let decodeError as NSError {
                error = decodeError
            }
        }
        
        return (locationsData, error)
    }
    
    // Utility method for retrieving data from app bundle resource.
    // returns boolean indicating success/Failure retrieving the data
    static public func generateWeatherDataFromBundleJSONFile( sourceFile:String ) -> (Weather?, NSError?) {
        var weatherData : Weather? = nil
        var error : NSError? = nil
        
        if let url = Bundle.main.url(forResource: sourceFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                weatherData = try decoder.decode(Weather.self, from: data)
                
            } catch let decodeError as NSError {
                error = decodeError
            }
        }
        
        return (weatherData, error)
    }
}
