//
//  ViewController.swift
//  Weather
//
//  Created by Piotr Sirek on 29/10/2018.
//  Copyright © 2018 Piotr Sirek. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var userLocalisation = CLLocationCoordinate2D()
    
    var weatherForecasts = [WeatherForecast]()
    var hourForecast = [HourForecast]()
    
    var actualSummary = String()
    var actualWeather = Int()
    var actualPressure = Double()
    var actualWind = Double()
    var actualChanceOfRain = Int()
    
    var forecastIcon: String? = String()
    var forecastDateDayname: String? = String()
    var forecastTemperature: Int? = Int()
    
    var hourForecastIcon: String? = String()
    var hourForecastHour: Int? = Int()
    var hourForecastTemperature: Int? = Int()
    
    var language = "en"
    var calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    var weatherURL: URL! = nil

    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var hoursForecastsCollectionView: UICollectionView!
    @IBOutlet weak var chanceOfRainLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var actualInfo: UILabel!
    @IBOutlet weak var actualWeatherLabel: UILabel!
    @IBOutlet weak var daysInfoTableView: UITableView!
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocalisation = manager.location!.coordinate
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.stopUpdatingLocation()
        }
        
        print(userLocalisation.latitude)
        print(userLocalisation.longitude)
        
        calendar.locale = Locale(identifier: language)
        dateFormatter.locale = Locale(identifier: language)
        weatherURL = URL(string: "https://api.darksky.net/forecast/0e52facc48f0791d78328d6fa79b2037/50.8118195,19.1203094?units=auto&lang=\(language)")
        
        getCurrentTemperature()
        getWeatherForecast()
        getHourForecast()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getCurrentTemperature() {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: weatherURL) {(data: Data?, response: URLResponse? ,error: Error?) in
            if let error = error {
                print("Error! \(error)") // work with errors to do
            } else if let data = data {
                let dataString = String(data: data, encoding: String.Encoding.utf8)
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    if let mainDictionary = jsonObject!.value(forKey: "currently") as? NSDictionary
                    {
                        if let summary = mainDictionary.value(forKey: "summary") {
                            DispatchQueue.main.async {
                                self.actualSummary = summary as! String
                                self.actualWeatherLabel.text = self.actualSummary
                            }
                        }
                        if let temperature = mainDictionary.value(forKey: "temperature") {
                            DispatchQueue.main.async {
                                self.actualWeather = Int(round(temperature as! Double))
                                self.actualInfo.text = "\(self.actualWeather)°"
                            }
                        }
                        if let windSpeed = mainDictionary.value(forKey: "windSpeed") {
                            DispatchQueue.main.async {
                                self.actualWind = windSpeed as! Double
                                self.windSpeedLabel.text = "\(self.actualWind) km/h"
                            }
                        }
                        if let chanceOfRain = mainDictionary.value(forKey: "precipProbability") {
                            DispatchQueue.main.async {
                                self.actualChanceOfRain = Int(chanceOfRain as! Double * 100)
                                self.chanceOfRainLabel.text = "\(self.actualChanceOfRain)%"
                            }
                        }
                        if let pressure = mainDictionary.value(forKey: "pressure") {
                            print(pressure)
                            DispatchQueue.main.async {
                                self.actualPressure = pressure as! Double
                                self.pressureLabel.text = "\(self.actualPressure) hPa"
                            }
                        }
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func getWeatherForecast() {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: weatherURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Some \(error) showed.")
            } else if let data = data {
                let dataString = String(data: data, encoding: String.Encoding.utf8)
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    if let dailyDictionary = jsonObject!.value(forKey: "daily") as? NSDictionary {
                        if let dataDictionary = dailyDictionary.value(forKey: "data") as? NSArray {
                            for index in 1...7 {
                                if let forecastDictionary = dataDictionary[index] as? NSDictionary {
                                    if let forecastDateValue = forecastDictionary.value(forKey: "time") {
                                        let forecastDate = Date(timeIntervalSince1970: forecastDateValue as! TimeInterval)
                                        self.forecastDateDayname = self.dateFormatter.weekdaySymbols[self.calendar.component(.weekday, from: forecastDate)-1]
                                        print(self.forecastDateDayname!)
                                    }
                                    if let forecastTemperatureValue = forecastDictionary.value(forKey: "temperatureHigh") {
                                        self.forecastTemperature = Int(round(forecastTemperatureValue as! Double))
                                        print(self.forecastTemperature!)
                                    }
                                    if let forecastIconValue = forecastDictionary.value(forKey: "icon"){
                                        self.forecastIcon = forecastIconValue as? String
                                        print(self.forecastIcon!)
                                    }
                                    self.weatherForecasts.append(WeatherForecast(dayOfWeek: self.forecastDateDayname ?? "Error", temperature: self.forecastTemperature ?? 0, icon: self.forecastIcon ?? "Error"))
                                    DispatchQueue.main.async {
                                        self.daysInfoTableView.reloadData()
                                    }
                                    print(self.weatherForecasts.count)
                                }
                            }
                        }
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func getHourForecast() {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: weatherURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Some \(error) showed.")
            } else if let data = data {
                let dataString = String(data: data, encoding: String.Encoding.utf8)
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    if let dailyDictionary = jsonObject!.value(forKey: "hourly") as? NSDictionary {
                        if let dataDictionary = dailyDictionary.value(forKey: "data") as? NSArray {
                            for index in 1...24 {
                                if let forecastDictionary = dataDictionary[index] as? NSDictionary {
                                    if let hourForecastHourValue = forecastDictionary.value(forKey: "time") {
                                        let forecastHour = Date(timeIntervalSince1970: hourForecastHourValue as! TimeInterval)
                                        self.hourForecastHour = self.calendar.component(.hour, from: forecastHour)
                                        print(self.hourForecastHour!)
                                    }
                                    if let hourForecastTemperatureValue = forecastDictionary.value(forKey: "temperature") {
                                        self.hourForecastTemperature = Int(round(hourForecastTemperatureValue as! Double))
                                        print(self.hourForecastTemperature!)
                                    }
                                    if let hourForecastIconValue = forecastDictionary.value(forKey: "icon"){
                                        self.hourForecastIcon = hourForecastIconValue as? String
                                        print(self.hourForecastIcon!)
                                    }
                                    self.hourForecast.append(HourForecast(hour: self.hourForecastHour ?? 0, temperature: self.hourForecastTemperature ?? 0, icon: self.hourForecastIcon ?? "Error"))
                                    DispatchQueue.main.async {
                                        self.hoursForecastsCollectionView.reloadData()
                                    }
                                    print(self.hourForecast.count)
                                }
                            }
                        }
                    }
                }
            }
        }
        dataTask.resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let forecast = weatherForecasts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "day", for: indexPath) as! DayOfWeekTableView
        cell.dayName.text = forecast.dayOfWeek
        cell.temperatureLabel.text = "\(forecast.temperature)"
        cell.weatherImage.image = UIImage(named: forecast.icon)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hour = hourForecast[indexPath.row]
        let cell = hoursForecastsCollectionView.dequeueReusableCell(withReuseIdentifier: "hours", for: indexPath) as! HourOfDayTableView
        cell.temperatureLabel.text = "\(hour.temperature)°"
        cell.weatherImage.image = UIImage(named: hour.icon)
        if hour.hour < 10 {
            cell.hourLabel.text = "0\(hour.hour)"
        } else {
            cell.hourLabel.text = "\(hour.hour)"
        }
        
        return cell
    }
}

class DayOfWeekTableView: UITableViewCell {
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var dayName: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
}

class HourOfDayTableView: UICollectionViewCell {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
}


