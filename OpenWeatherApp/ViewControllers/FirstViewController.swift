//
//  FirstViewController.swift
//  OpenWeatherApp
//
//  Created by MAC on 25.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    private let openWeatherMapBaseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "368e827be4b38db51ff960ca88b5c396"
    
    // Ekaterinburg for testing = 56.8519 60.6122
    var lat: Double?
    var lon: Double?

    let locationManager = CLLocationManager()
    
//MARK: Outlets
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingActivity.startAnimating()
        
        locationManager.requestWhenInUseAuthorization()
        addObservers()

    }
    
    //MARK: Observing background statement
    fileprivate  func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    fileprivate  func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc fileprivate func applicationDidBecomeActive() {
        print(#function)
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: Update Weather Button
    @IBAction func updateWeather() {
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: Getting Weather from user Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Getting coordinates
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        print(lat as Any)
        print(lon as Any)
        
        let myDate = Date()
        let formatter = DateFormatter()
        
        //Parsing JSON
        let weatherRequestURL = openWeatherMapBaseURL+"?lat=\(lat!)&lon=\(lon!)&appid=\(openWeatherMapAPIKey)&units=metric"
        guard let url = URL(string: weatherRequestURL) else {
            showRedAllert(title: "URL missing", message: "Sorry, connection refused")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            do {
                let showMyWeather = try JSONDecoder().decode(Weather.self, from: data)
                let temp = String(round(showMyWeather.main.temp))
                let name = showMyWeather.name
                let imageName = showMyWeather.weather[0].icon
                
                
                DispatchQueue.main.async {
                    self.cityName.text = name
                    self.currentTemp.text = "\(temp) °С"
                    self.weatherImage.image = UIImage (named: imageName)
                    
                    formatter.dateFormat = "HH:mm dd/MM/yyyyy"
                    let dateTime = formatter.string(from: myDate)
                    
                    CoreManager.saveObject(data: temp, date: dateTime, icon: imageName)
                }
            }catch let error {
                print(error)
                self.showRedAllert(title: "Data missing", message: "Sorry, cant decode data from URL")
            }
        }.resume()
        
        self.locationManager.stopUpdatingLocation()
        loadingActivity.stopAnimating()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        showRedAllert(title: "GPS Error", message: "Sory, but cant retrieve location.")
    }
    
    deinit {
        removeObservers()
    }
}

extension FirstViewController {
    private func showRedAllert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
