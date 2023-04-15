//
//  WebServices.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation
import UIKit

// A gateway to web based API services.
class NetworkQueryService {
    
    //API details and Weather API Key
    enum Constants {
       static let APIKey = "186e8c5a17b904142db18a6ab86177cf"
       static let geocodeAPIStr = "https://api.openweathermap.org/geo/1.0/direct"
       static let reverseGeoAPIStr = "https://api.openweathermap.org/geo/1.0/reverse"
       static let weatherAPIStr = "https://api.openweathermap.org/data/2.5/weather"
       static var iconImageURLStr = "https://openweathermap.org/img/wn"
       static let resultsLimit = 3
        
    }
   
    //MARK: - properties
    lazy var defaultSession : URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()
    
    var locationDataTask : URLSessionDataTask?
    var weatherDataTask : URLSessionDataTask?
    
    let decoder = JSONDecoder()
    
    //API to get location details for given search string
    func getLocationSearchResults( searchTerm:String, completionHandler : @escaping ([Location]?, NSError?) -> () ) {
        locationDataTask?.cancel()
        
        guard searchTerm != "" else { return }
        
        guard var components = URLComponents(string: Constants.geocodeAPIStr) else { return }
        
        components.query = "q=\(searchTerm)&limit=\(Constants.resultsLimit)&appid=\(Constants.APIKey)"
        
        guard let urlRequest = components.url else { return }
        locationDataTask = defaultSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.locationDataTask = nil }
            
            var locations : [Location]? = nil
            var locServiceError : NSError? = nil
            
            if let error = error {
                locServiceError = error as NSError
            } else if let data = data, let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                (locations, locServiceError) = self.parseLocationDataResponse(data)
            }
            completionHandler(locations, locServiceError)
        }
        locationDataTask?.resume()
    }
    
    //Converting given response data to Location Model data
    fileprivate func parseLocationDataResponse( _ data : Data ) -> ([Location]?, NSError?) {
        var locations : [Location]? = nil
        var locServiceError :NSError? = nil
        
        do {
            locations = try decoder.decode([Location].self, from: data)
        } catch let decodeError as NSError {
            locServiceError = decodeError
            return (nil, locServiceError)
        }
        return (locations, nil)
    }
    
    //API to get location details for given longitude and latitude details
    func getLocationSearchResults( lat:Double, lon:Double, completionHandler : @escaping ([Location]?, NSError?) -> () ) {
        locationDataTask?.cancel()
        
        guard var components = URLComponents(string: Constants.reverseGeoAPIStr) else { return }
        
        components.query = "lat=\(lat)&lon=\(lon)&limit=1&appid=\(Constants.APIKey)"
        
        guard let urlRequest = components.url else { return }
        locationDataTask = defaultSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.locationDataTask = nil }
            
            var locations : [Location]? = nil
            var locServiceError : NSError? = nil
            
            if let error = error {
                locServiceError = error as NSError
            } else if let data = data, let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                (locations, locServiceError) = self.parseLocationDataResponse(data)
            }
            completionHandler(locations, locServiceError)
        }
        locationDataTask?.resume()
    }
    
    func getWeatherSearchResults( latitude:Double, longitude:Double, completionHandler : @escaping (Weather?, NSError?) -> () ) {
        weatherDataTask?.cancel()
        
        guard var components = URLComponents(string: Constants.weatherAPIStr) else { return }
        
        components.query = "lat=\(latitude)&lon=\(longitude)&appid=\(Constants.APIKey)"
        guard let urlRequest = components.url else { return }
        
        weatherDataTask = defaultSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.weatherDataTask = nil }
            
            var weather : Weather? = nil
            var weatherServiceError : NSError? = nil
            
            if let error = error {
                weatherServiceError = error as NSError
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                (weather, weatherServiceError) = self.parseWeatherDataResponse(data)
            }
            completionHandler(weather, weatherServiceError)
        }
        weatherDataTask?.resume()
    }
    
    fileprivate func parseWeatherDataResponse( _ data : Data ) -> (Weather?, NSError?) {
        
        var weather : Weather? = nil
        var weatherServiceError : NSError? = nil
        
        do {
            weather = try decoder.decode(Weather.self, from: data)
        } catch let decodeError as NSError {
            weatherServiceError = decodeError
        }
        return (weather, weatherServiceError)
    }
    
    func downloadImage( resource : String, completionHandler : @escaping (UIImage?, NSError?) -> Void ) {
        guard resource != "" else { return }
        
        let url = URL(string: Constants.iconImageURLStr + "/" + resource + "@2x.png")!
        let imageDataTask = defaultSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error as? NSError {
                completionHandler(nil, error)
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let image = UIImage(data: data)
                completionHandler(image, nil)
            }
        }
        imageDataTask.resume()
    }
}
