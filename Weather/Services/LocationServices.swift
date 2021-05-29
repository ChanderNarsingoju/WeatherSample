//
//  LocationServices.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/27/21.
//

import Foundation
import MapKit


struct Address: Codable {
    var city: String = ""
    var state: String = ""
    var name: String = ""
    var country: String = ""
    var countryCode: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
}

class LocationServices {
    
    /// Getting the location address details
    /// - Parameters:
    ///   - location: location object
    ///   - completion: completion handler
    /// - Returns: returns the location address details
    func getAdress(location:CLLocation, completion: @escaping (_ address: Address?, _ error: Error?) -> ()) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            
            if let e = error {
                
                completion(nil, e)
                
            } else {
                
                var address = Address()
                address.lat = location.coordinate.latitude
                address.long = location.coordinate.longitude
                // Place details
                guard let placeMark = placemarks?.first else { return }
                    
                // City
                if let city = placeMark.locality {
                    print(city)
                    address.city = city
                }
                //State Code
                if let stateCode = placeMark.administrativeArea {
                    print(stateCode)
                    address.state = stateCode
                }
                
                // Country
                if let country = placeMark.country {
                    print(country)
                    address.country = country
                }
                
                // Country
                if let countryCode = placeMark.isoCountryCode {
                    print(countryCode)
                    address.countryCode = countryCode
                }
                
                // Name
                if let name = placeMark.name {
                    print(name)
                    address.name = name
                }
                completion(address, nil)
            }
            
        }
    }

}
