//
//  WeatherDependencyProvider.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

class WeatherDependencyProvider {
    static let shared = WeatherDependencyProvider()
    
    let appScopeDependencyContainer = AppScopeDependencyProvider.shared
    
    let curWeatherInfoVM : WeatherViewModel
    let weatherQueryController : WeatherQueryController
    
    private init() {
        weatherQueryController = WeatherQueryController(dataSourcer: appScopeDependencyContainer.sharedDataSource, imgCache: appScopeDependencyContainer.imageCache)
        
        curWeatherInfoVM = WeatherViewModel(weatherQueryController: weatherQueryController)
    }
    
    func makeSearchCurWeatherInfoVM(weatherQueryController : WeatherQueryController) -> WeatherViewModel{
        return WeatherViewModel(weatherQueryController: weatherQueryController)
    }
}
