//
//  LocationsViewModel.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/27/21.
//

import Foundation
import UIKit

public class LocationsViewModel {
    var userDefaults = UserDefaults.standard
    
    var locationsList = [Address]()
    var filteredList = [Address]()
    var isSearchApplied = false
    
    func getLocationsCout() -> Int {
        var list = getLocationsFromDefaults()
        if isSearchApplied {
            list = filteredList
        }
        return list?.count ?? 0
    }
    
    func addAddress(location: Address) {
        setLocationToDefaults(location: location)
    }
    
    func getLocationForIndex(index: Int) -> Address {
        var locList = locationsList
        if isSearchApplied {
            locList = filteredList
        }
        return locList[index] 
    }
    
    func getLocationsFromDefaults() -> [Address]? {
        if let data = userDefaults.data(forKey: LOCATIONS_KEY) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                // Decode Locations
                let locations = try decoder.decode([Address].self, from: data)
                locationsList = locations
                return locations
            } catch {
                print("Unable to Decode Locations (\(error))")
            }
        }
        return nil
    }
    
    func setLocationToDefaults(location: Address) {
        var locList = [location]
        if let data = getLocationsFromDefaults() {
            locList = data
            locList.append(location)
        }
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            // Encode Locations
            let data = try encoder.encode(locList)
            // Write/Set Data
            userDefaults.set(data, forKey: LOCATIONS_KEY)
            userDefaults.synchronize()
        } catch {
            print("Unable to Encode Locations (\(error))")
        }
    }
    
    func deleteLocationFor(index: Int) {
        if let data = getLocationsFromDefaults() {
            var locList = data
            var removableItem = locList[index]
            if isSearchApplied {
                removableItem = filteredList[index]
                filteredList.remove(at: index)
            }
            
            locList.removeAll { (address) -> Bool in
                if address.city == removableItem.city && address.name == removableItem.name {
                    return true
                } else {
                    return false
                }
            }
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()
                // Encode Locations
                let data = try encoder.encode(locList)
                // Write/Set Data
                userDefaults.set(data, forKey: LOCATIONS_KEY)
                userDefaults.synchronize()
            } catch {
                print("Unable to Encode Locations (\(error))")
            }
        }
    }
    
    func clearAllBookmarkedLocations() {
        userDefaults.removeObject(forKey: LOCATIONS_KEY)
    }
    
    //MARK: Search Delegate
    /// Searchbar text did change will call for every individual text entered on search bar
    ///
    /// - Parameters:
    ///   - searchBar: search bar
    ///   - searchText: entered text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.isEmpty {
            isSearchApplied = false
        } else {
            isSearchApplied = true
        }
        let filtered = locationsList.filter {
         return $0.city.range(of: searchText, options: .caseInsensitive) != nil || $0.state.range(of: searchText, options: .caseInsensitive) != nil || $0.country.range(of: searchText, options: .caseInsensitive) != nil || $0.name.range(of: searchText, options: .caseInsensitive) != nil
         }
         filteredList = filtered
    }
    
    /// Search bar cancel button method will call on click `cancel` button on search bar.
    ///
    /// - Parameter searchBar: search bar.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchApplied = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
