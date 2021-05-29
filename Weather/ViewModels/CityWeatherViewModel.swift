//
//  CityWeatherViewModel.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/29/21.
//

import Foundation
public class CityWeatherViewModel {
    var userDefaults = UserDefaults.standard
    var location: Address!
    
    /// Clearing all bookmarked locations
    func clearAllBookmarkedLocations() {
        userDefaults.removeObject(forKey: LOCATIONS_KEY)
    }
    
    
    /// Get wether details for particular location for current date
    /// - Parameters:
    ///   - units: units for wether details
    ///   - onSuccess: success handler
    ///   - onError: error handler
    func getWeatherForLocation(units: String, onSuccess: @escaping (WeatherCurrent) -> Void, onError: @escaping (String) -> Void) {
        APIManager.instance.getWeatherForLocation(lat: "\(location.lat)", long: "\(location.long)", unit: units) { (weather) in
            print(weather)
            onSuccess(weather)
        } onError: { (error) in
            print(error)
            onError(error)
        }
    }
    
    
    /// Get daily weather details for few days for a location
    /// - Parameters:
    ///   - units: units for weather details
    ///   - onSuccess: success handler
    ///   - onError: error handler
    func getWeatherDailyForLocation(units: String, onSuccess: @escaping (WeatherDailyData) -> Void, onError: @escaping (String) -> Void) {
        APIManager.instance.getWeatherDailyForLocation(lat: "\(location.lat)", long: "\(location.long)", unit: units) { (weatherDailyData) in
            print(weatherDailyData)
            onSuccess(weatherDailyData)
        } onError: { (error) in
            print(error)
            onError(error)
        }
    }
    
    
}
