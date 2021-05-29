//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by Narsingoju Chander on 5/27/21.
//

import XCTest
@testable import Weather

class WeatherTests: XCTestCase {
    let viewModel = LocationsViewModel()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //Using dummy json data
    func testDummyJsonFileExistance() {
        let locationDetails = readJsonFromFile(withFileName: "weather")
        print(locationDetails)
        do {
            let responseData = try JSONDecoder().decode(Address.self, from: locationDetails.1 ?? Data())
            XCTAssertNotNil(responseData, "No Data")
            
            //Inserting location object into defaults.
            viewModel.setLocationToDefaults(location: responseData)
            let locations = viewModel.getLocationsFromDefaults()
            
            //Testing  locations count.
            XCTAssertNotNil(locations, "No Locations")
            XCTAssertGreaterThan(Int(locations?.count ?? 0), 0, "Location not added.")
        } catch {
            print(error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAddLocation() {
        let locationDetails = readJsonFromFile(withFileName: "weather")
        print(locationDetails)
        do {
            let responseData = try JSONDecoder().decode(Address.self, from: locationDetails.1 ?? Data())
            XCTAssertNotNil(responseData, "No Data")
            viewModel.setLocationToDefaults(location: responseData)
            let locations = viewModel.getLocationsFromDefaults()
            //Testing locations add.
            XCTAssertNotNil(locations, "No Locations")
        } catch {
            print(error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLocationDelete() {
        
        let locationDetails = readJsonFromFile(withFileName: "weather")
        print(locationDetails)
        do {
            let responseData = try JSONDecoder().decode(Address.self, from: locationDetails.1 ?? Data())
            XCTAssertNotNil(responseData, "No Data")
            let city = responseData.city
            viewModel.setLocationToDefaults(location: responseData)
            let locations = viewModel.getLocationsFromDefaults()
            
            //Testing last location details with added location
            XCTAssertEqual(locations?.last?.city, city, "Locations city did not match.")
            
            //Testing location delete
            viewModel.deleteLocationFor(index: (locations?.count ?? 1) - 1)
            
            let locations2 = viewModel.getLocationsFromDefaults()
            XCTAssertNotEqual(locations2?.last?.city, city, "Locations city got matched. Hence deletion failed.")
            
        } catch {
            print(error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testRemoveAllLocations() {
        testAddLocation()
        let locations = viewModel.getLocationsFromDefaults()
        XCTAssertGreaterThan(Int(locations?.count ?? 0), 0, "Location not added.")
        
        //Testing clearing all the locations.
        viewModel.clearAllBookmarkedLocations()
        let locations1 = viewModel.getLocationsFromDefaults()
        XCTAssertNil(locations1, "Locations not cleared.")
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func readJsonFromFile(withFileName fileName:String) -> ([String: Any]?, Data?) {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
            do {
                let text = try String(contentsOfFile: path, encoding: .utf8)
                if let dict = try JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                    return (dict, text.data(using: .utf8)!)
                }
            }catch {
                print("\(error.localizedDescription)")
            }
        }
        
        return (nil, nil)
    }
    
}
