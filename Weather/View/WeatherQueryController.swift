//
//  WeatherQueryController.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation
import UIKit.UIImage

class WeatherQueryController {
    private let imageCache : ImageCache
    private let dataSource : DataSource
    private var currentLocation : Location?
    private var currentWeatherData : Weather?
    
    init(dataSourcer : DataSource, imgCache : ImageCache) {
        dataSource = dataSourcer
        imageCache = imgCache
    }
    
    func queryCityWeatherInfo( searchStr : String, completionHandler : @escaping ([Location]?, Weather?) -> Void ) {
        let trimmedStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let completion = { [weak self] ( locationDataList : [Location]?, error : NSError? ) in
            guard let self = self else { return }
            if error != nil {
                completionHandler(nil, nil)
            } else if locationDataList == nil || locationDataList!.count == 0 {
                completionHandler(nil, nil)
            } else if (locationDataList?.count == 1) {
                self.currentLocation = locationDataList![0]
                DispatchQueue.global(qos:.userInitiated).async {
                    self.queryCurrentWeatherInfo(currentLocation: self.currentLocation!) {
                        [weak self] weatherData in
                        if let self = self, var weatherData = weatherData {
                            self.loadImage(resourceStr: weatherData.currentWeather[0].iconId) {
                                image, error in
                                if let image = image {
                                    weatherData.currentWeather[0].icon = image
                                }
                                completionHandler(locationDataList, weatherData)
                            }
                        } else {
                            completionHandler(nil, nil)
                        }
                    }
                }
            } else {
                completionHandler(locationDataList, nil)
            }
        }
        
        let splits = trimmedStr.split(separator: ",")
        if (splits.count == 1) {
            dataSource.generateLocationData(city: String(splits[0]), state: "", completionHandler:completion)
        } else if (splits.count == 2) {
            dataSource.generateLocationData(city: String(splits[0]), state:String(splits[1]), completionHandler: completion)
        } else {
            completionHandler(nil, nil)
        }
    }
    
    func queryCityWeatherInfoReverse( latitude : Double, longitude : Double, completionHandler : @escaping ([Location]?, Weather?) -> Void ) {
        
        let completion = { ( locationDataList : [Location]?, error : NSError? ) in
            if error != nil {
                completionHandler(nil, nil)
            } else if locationDataList == nil || locationDataList!.count == 0 {
                completionHandler(nil, nil)
            } else if (locationDataList?.count == 1) {
                self.currentLocation = locationDataList![0]
                let execQueue = DispatchQueue.global(qos:.userInitiated)
                execQueue.async {
                    self.queryCurrentWeatherInfo(currentLocation: self.currentLocation!) {
                        [weak self] weatherData in
                        if let self = self, var weatherData = weatherData {
                            self.loadImage(resourceStr: weatherData.currentWeather[0].iconId) {
                                image, error in
                                if let image = image {
                                    weatherData.currentWeather[0].icon = image
                                }
                                completionHandler(locationDataList, weatherData)
                            }
                        } else {
                            completionHandler(nil, nil)
                        }
                    }
                }
            } else {
                completionHandler(locationDataList, nil)
            }
        }
        
        dataSource.generateLocationData(lat: latitude, lon: longitude, completionHandler: completion)
    }
    
    func queryCurrentWeatherInfo( currentLocation : Location, completionHandler : @escaping (Weather?) -> Void ) {
        dataSource.generateWeatherData(currentLocationData: self.currentLocation!) { weatherData, error in
            if error != nil {
                completionHandler(nil)
            } else {
                completionHandler(weatherData)
            }
        }
    }
    
    func loadImage( resourceStr : String, completionHandler : @escaping (UIImage?, NSError?) -> Void ) {
        if let image = imageCache[resourceStr] {
            completionHandler(image, nil)
            return
        }
        
        let networkingService = AppScopeDependencyProvider.shared.networkingService
        networkingService.downloadImage(resource: resourceStr) {
            [weak self] image, error in
            if let self = self, let image = image {
                self.imageCache[resourceStr] = image
            }
            completionHandler(image, error)
        }
    }
}
