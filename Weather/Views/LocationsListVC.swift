//
//  ViewController.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/27/21.
//

import UIKit
import MapKit

class LocationsListVC: UIViewController, CLLocationManagerDelegate {
    ///Out lets and Variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var settingsView: UIView!
    @IBOutlet weak var unitsSigment: UISegmentedControl!
    
    let locationManager = CLLocationManager()

    let viewModel = LocationsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up map delegates and properties
        initializeMapView()
        
        createLogpressGesture()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let units = viewModel.userDefaults.string(forKey: UNIT_TYPE) ?? UnitTypes.IMPERIAL.rawValue
        if units == UnitTypes.IMPERIAL.rawValue {
            unitsSigment.selectedSegmentIndex = 0
        } else {
            unitsSigment.selectedSegmentIndex = 1
        }
        
        loadLocationPinsOnMap()
        collectionView.reloadData()
    }
    
    ///Setting current user location permission and map properties.
    func initializeMapView() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    
    ///Creating long press gesture on map
    func createLogpressGesture() {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }

    /// Handling longpress gesture to add pin on map.
    /// - Parameter gestureRecognizer: gesture recognizer
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }

        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                
        let location = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        if Reachability.isConnectedToNetwork(){
            LocationServices().getAdress(location: location) { (address, error) in
                self.viewModel.addAddress(location: address ?? Address())
                self.collectionView.reloadData()
                self.addPinOnMap(location: address ?? Address())
            }
        } else {
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Network Error", message: "Internet Connection not Available!\nPlease connect to internet to get location details.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
    }
    
    ///Loading map pins based on bookmarked/saved locations.
    func loadLocationPinsOnMap(){
        if let locations = viewModel.getLocationsFromDefaults() {
            for location in locations {
               addPinOnMap(location: location)
            }
        } else {
            removeAllPinsFromMap()
        }
    }
    
    /// Adding pin for particular location
    /// - Parameter location: location details
    func addPinOnMap(location: Address) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
        annotation.title = location.city
        annotation.subtitle = location.state
        let pinAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
    }
    
    /// Removing pin from the map for particular location
    /// - Parameter coordinates: location coordinates.
    func removePinFromMap(coordinates: CLLocationCoordinate2D) {
        for annotation in mapView.annotations {
            if annotation.coordinate.latitude == coordinates.latitude && annotation.coordinate.longitude == coordinates.longitude {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    /// Removing pins from the map
    /// - Parameter coordinates: location coordinates.
    func removeAllPinsFromMap() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    /// View transition to handle views in potrait and landscape orientation changes.
    /// - Parameters:
    ///   - size: size of the view
    ///   - coordinator: coordinator
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        settingsView.removeFromSuperview()
        collectionView.reloadData()
    }
    
    /// Help button action to show Help page
    /// - Parameter sender: sender object
    @IBAction func helpAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil)
        let helpScreen = storyBoard.instantiateViewController(withIdentifier: HELP_SCREEN_IDENTIFIER) as! HelpScreenVC
        self.navigationController?.pushViewController(helpScreen, animated: true)
    }
    
    /// Back button action to show settings page
    /// - Parameter sender: sender object
    @IBAction func settingsAction(_ sender: Any) {
        settingsView.frame = self.view.frame
        self.view.addSubview(settingsView)
    }
    
    /// Segment value change action
    /// - Parameter sender: segment
    @IBAction func unitSigmentsChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewModel.userDefaults.setValue(UnitTypes.IMPERIAL.rawValue, forKey: UNIT_TYPE)
        } else {
            viewModel.userDefaults.setValue(UnitTypes.METRIC.rawValue, forKey: UNIT_TYPE)
        }
        viewModel.userDefaults.synchronize()
    }
    
    /// Clearing bookmark locations action
    /// - Parameter sender: sender
    @IBAction func clearBookMarkedLocations(_ sender: Any) {
        viewModel.clearAllBookmarkedLocations()
        removeAllPinsFromMap()
        collectionView.reloadData()
    }
    
    /// Closing settings view
    /// - Parameter sender: sender
    @IBAction func closeSettingsView(_ sender: Any) {
        settingsView.removeFromSuperview()
    }
}

extension LocationsListVC: MKMapViewDelegate {
    //MARK:- MapView Delegate Methods
    /// MapView delegate for annotation views.
    /// - Parameters:
    ///   - mapView: mapview object
    ///   - annotation: annotation
    /// - Returns: returns the annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.animatesDrop = true
        annotationView?.canShowCallout = true
        if annotationView == nil {
            print("Error")
        }
        
        return annotationView
    }
}

extension LocationsListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getLocationsCout()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LocationCell = collectionView.dequeueReusableCell(withReuseIdentifier: LOCATION_CELL_IDENTIFIER, for: indexPath) as! LocationCell
        let address = viewModel.getLocationForIndex(index: indexPath.item)
        
        cell.locationNameLbl.text = address.name
        cell.cityNameLbl.text = address.city
        cell.stateNameLbl.text = "\(address.state), \(address.country)"
        cell.deleteBtn.tag = indexPath.item
        cell.deleteBtn.addTarget(self, action: #selector(deleteLocation(button:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let address = viewModel.getLocationForIndex(index: indexPath.item)
        let storyBoard : UIStoryboard = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil)
        let cityWeather = storyBoard.instantiateViewController(withIdentifier: CITY_WEATHER_IDENTIFIER) as! CityWeatherVC
        cityWeather.viewModel.location = address
        self.navigationController?.pushViewController(cityWeather, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 111)
    }
    
    
    /// Deleting the location from the bookmarked
    /// - Parameter button: delete button
    @objc func deleteLocation(button: UIButton) {
        let address = viewModel.getLocationForIndex(index: button.tag)
        viewModel.deleteLocationFor(index: button.tag)
        collectionView.reloadData()
        removePinFromMap(coordinates: CLLocationCoordinate2D(latitude: address.lat, longitude: address.long))
    }
}

extension LocationsListVC: UISearchBarDelegate {
    //MARK: Search Delegate
    /// Searchbar text did change will call for every individual text entered on search bar
    ///
    /// - Parameters:
    ///   - searchBar: search bar
    ///   - searchText: entered text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        viewModel.searchBar(searchBar, textDidChange: searchText)
        collectionView.reloadData()
    }
    
    /// Search bar cancel button method will call on click `cancel` button on search bar.
    ///
    /// - Parameter searchBar: search bar.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchBarCancelButtonClicked(searchBar)
        collectionView.reloadData()
    }
    
    /// Search bar search button method will call on click `Search` button
    ///
    /// - Parameter searchBar: search bard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.canResignFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}


/// Collectionview cell class
class LocationCell: UICollectionViewCell {
    
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var stateNameLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!

}
