//
//  NetworkDataSource.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

class NetworkDataSource : DataSource {
    var source : ContentSourceType = .bundleJSON
    var weatherData: Weather?
    var locationsData : [String : [Location]] = [String : [Location]]()
    
    let defaultCountry = "US" // Could be populated using a configuration class
    
    func generateLocationData(
        city : String,
        state: String,
        completionHandler : @escaping ([Location]?, NSError?) -> Void
    ) {
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
        
        if  locationsData[searchTerm] != nil {
            completionHandler(locationsData[searchTerm], nil)
            return
        }
            
        DispatchQueue.global(qos:.userInitiated).async {
            AppScopeDependencyProvider.shared.networkingService.getLocationSearchResults(searchTerm: searchTerm) {
                [weak self] locationList, error in
                var localList = locationList
                if localList != nil && localList!.count > 0 {
                    if state != "" && localList!.count > 1 {
                        while localList!.count > 1 { localList!.removeLast() }
                    }
                }
                if let error = error {
                    completionHandler(nil, error as NSError)
                } else {
                    self?.locationsData[searchTerm] = localList
                    completionHandler(localList, nil)
                }
            }
        }
    }
    
    func generateLocationData(
        lat : Double,
        lon : Double,
        completionHandler: @escaping ([Location]?, NSError?) -> Void
    ) {
                
        DispatchQueue.global(qos:.userInitiated).async {
            AppScopeDependencyProvider.shared.networkingService.getLocationSearchResults(lat : lat, lon : lon) {
                [weak self] locationList, error in
                var localList = locationList
                if localList != nil && localList!.count > 0 {
                    if localList!.count > 1 {
                        while localList!.count > 1 { localList!.removeLast() }
                    }
                }
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    let searchTerm = localList![0].name + "," + localList![0].state + "," + localList![0].country
                    self?.locationsData[searchTerm] = localList
                    completionHandler(localList, nil)
                }
            }
        }
    }
    
    func generateWeatherData(
        currentLocationData : Location,
        completionHandler: @escaping (Weather?, NSError?) -> Void
    ) {
        DispatchQueue.global(qos:.userInitiated).async {
            AppScopeDependencyProvider.shared.networkingService.getWeatherSearchResults(
                latitude: currentLocationData.latitude,
                longitude: currentLocationData.longitude
            ) { [weak self] weather, error in
                self?.weatherData = weather
                completionHandler(weather, nil)
            }
        }
    }
}

