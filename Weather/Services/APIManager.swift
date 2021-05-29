//
//  APIManager.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/27/21.
//

import Foundation
class APIManager {
    
    static let instance = APIManager()
    private init() {}
    
    /// API call to get wether details for particular location for current date
    /// - Parameters:
    ///   - lat: lattitude value
    ///   - long: longitude value
    ///   - unit: units for wether details
    ///   - onSuccess: success handler
    ///   - onError: error handler
    func getWeatherForLocation(lat: String, long:String, unit: String, onSuccess: @escaping (WeatherCurrent) -> Void, onError: @escaping (String) -> Void) {
        let urlString = "\(BASE_URL_WEATHER)lat=\(lat)&lon=\(long)&units=\(unit)&appid=\(API_KEY)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            onError("Error in URL")
            return
        }
        
        let task = URLSession.shared
        task.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid data or response")
                    return
                }
                do {
                    if response.statusCode == 200 {
                        let responseData = try JSONDecoder().decode(WeatherCurrent.self, from: data)
                        print(responseData)
                        onSuccess(responseData)
                    } else {
                        onError("Error response with status code \(response.statusCode)")
                    }
                } catch {
                    onError(error.localizedDescription)
                }
            }
            
        }.resume()
    }
    
    /// API call to get daily weather details for few days for a location
    /// - Parameters:
    ///   - lat: latitude value
    ///   - long: longitude
    ///   - unit: units for weather details
    ///   - onSuccess: success handler
    ///   - onError: error handler
    func getWeatherDailyForLocation(lat: String, long:String, unit: String, onSuccess: @escaping (WeatherDailyData) -> Void, onError: @escaping (String) -> Void) {
        let urlString = "\(BASE_URL_FORECAST_DAILY)lat=\(lat)&lon=\(long)&exclude=hourly,minutely,current&units=\(unit)&appid=\(API_KEY)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            onError("Error in URL")
            return
        }
        
        let task = URLSession.shared
        task.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid data or response")
                    return
                }
                do {
                    if response.statusCode == 200 {
                        let responseData = try JSONDecoder().decode(WeatherDailyData.self, from: data)
                        print(responseData)
                        onSuccess(responseData)
                    } else {
                        onError("Error response with status code \(response.statusCode)")
                    }
                } catch {
                    onError(error.localizedDescription)
                }
            }
            
        }.resume()
    }
}
