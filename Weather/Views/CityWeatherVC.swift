//
//  CityWeatherVC.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/28/21.
//

import UIKit

class CityWeatherVC: UIViewController {
    
    ///Out lets and Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var weatherTypeLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var minMaxTempLbl: UILabel!
    
    @IBOutlet weak var sunriseLbl: UILabel!
    @IBOutlet weak var sunsetLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windLbl: UILabel!
    @IBOutlet weak var feelsLikeLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var unitsSigment: UISegmentedControl!
    @IBOutlet var settingsView: UIView!
    
    let viewModel = CityWeatherViewModel()
    
    var list = [Daily]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let units = viewModel.userDefaults.string(forKey: UNIT_TYPE) ?? UnitTypes.IMPERIAL.rawValue
        loadLocationWeatherDetails(units: units)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let units = viewModel.userDefaults.string(forKey: UNIT_TYPE) ?? UnitTypes.IMPERIAL.rawValue
        if units == UnitTypes.IMPERIAL.rawValue {
            unitsSigment.selectedSegmentIndex = 0
        } else {
            unitsSigment.selectedSegmentIndex = 1
        }
        
    }
    
    /// Loading location weather details by calling API
    /// - Parameter units: units for weather details
    func loadLocationWeatherDetails(units: String) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            viewModel.getWeatherForLocation(units: units) { (weather) in
                self.updateUIData(weather: weather)
            } onError: { (error) in
                print(error)
            }

            viewModel.getWeatherDailyForLocation(units: units) { (weatherDailyData) in
                self.list = weatherDailyData.daily
                self.collectionViewHeightConstraint.constant = CGFloat((self.list.count + 3) * 50)
                self.collectionView.reloadData()
            } onError: { (error) in
                print(error)
            }
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Network Error", message: "Internet Connection not Available!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
        
    }
    
    /// View transition to handle views in potrait and landscape orientation changes.
    /// - Parameters:
    ///   - size: size of the view
    ///   - coordinator: coordinator
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        settingsView.removeFromSuperview()
        collectionView.reloadData()
    }
    
    /// Updating weather details
    /// - Parameter weather: wether details object
    func updateUIData(weather: WeatherCurrent) {
        cityNameLbl.text = weather.name
        weatherTypeLbl.text = weather.weather.first?.main
        tempLbl.text = "\(weather.main.temp)°"
        minMaxTempLbl.text = "H:\(weather.main.tempMax)°  L:\(weather.main.tempMin)°"
        humidityLbl.text = "\(weather.main.humidity)%"
        windLbl.text = "WNW \(weather.wind.speed) kph"
        feelsLikeLbl.text = "\(weather.main.feelsLike)°"
        pressureLbl.text = "\(weather.main.pressure) hPa"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"

        let sunriseTime = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(weather.sys.sunrise)))
        let sunsetTime = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(weather.sys.sunset)))
        sunriseLbl.text = "\(sunriseTime)"
        sunsetLbl.text = "\(sunsetTime)"
    }
    
    /// Back button action to move back to home page
    /// - Parameter sender: sender object
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
            loadLocationWeatherDetails(units: UnitTypes.IMPERIAL.rawValue)
        } else {
            viewModel.userDefaults.setValue(UnitTypes.METRIC.rawValue, forKey: UNIT_TYPE)
            loadLocationWeatherDetails(units: UnitTypes.METRIC.rawValue)
        }
        viewModel.userDefaults.synchronize()
    }
    
    /// Clearing bookmark locations action
    /// - Parameter sender: sender
    @IBAction func clearBookMarkedLocations(_ sender: Any) {
        viewModel.clearAllBookmarkedLocations()
        collectionView.reloadData()
    }
    
    /// Closing settings view
    /// - Parameter sender: sender
    @IBAction func closeSettingsView(_ sender: Any) {
        settingsView.removeFromSuperview()
    }
    
}

extension CityWeatherVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: COLLECTIONVIEW_CELL_IDENTIFIER, for: indexPath) as! CollectionViewCell
        let dailyData = list[indexPath.item]
        
        cell.weatherLbl.text = dailyData.weather.first?.main
        cell.tempLbl.text = "\(dailyData.temp.day)°"
        cell.humidityLbl.text = "\(dailyData.humidity)%"
        cell.windLbl.text = "\(dailyData.windSpeed)kph"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE dd"

        let day = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(dailyData.dt)))
        cell.dayLbl.text = day
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.view.layoutIfNeeded()
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var reuseableView: UICollectionReusableView!
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            reuseableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                            withReuseIdentifier: COLLECTIONVIEW_HEADER_IDENTIFIER,
                            for: indexPath)
            return reuseableView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
        
        return reuseableView
    }
    
}


/// Collection view header class
class CollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var weatherLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

/// Collectionview cell class
class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var weatherLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
