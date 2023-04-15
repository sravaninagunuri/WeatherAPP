//
//  AppScopeDependencyProvider.swift
//  Weather
//
//  Created by Sravani Nagunuri on 4/14/23.
//

import Foundation

class AppScopeDependencyProvider {
    static let shared = AppScopeDependencyProvider()
    
    let sharedDataSource : DataSource
    let networkingService = NetworkQueryService()
    let imageCache = ImageCache(memoryLimit: 1024*1024*100)
    
    private init() {
        sharedDataSource = NetworkDataSource()
    }
    
    func makeDataSource( ofType sourceType : ContentSourceType ) -> DataSource {
        return LocalJsonDataSource()
    }
}
