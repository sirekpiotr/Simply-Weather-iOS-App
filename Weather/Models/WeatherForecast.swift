//
//  WeatherForecast.swift
//  Weather
//
//  Created by Piotr Sirek on 01/11/2018.
//  Copyright © 2018 Piotr Sirek. All rights reserved.
//

import Foundation

class WeatherForecast {
    var dayOfWeek = String()
    var temperature = Int()
    var icon = String()
    
    init(dayOfWeek: String, temperature: Int, icon: String) {
        self.dayOfWeek = dayOfWeek
        self.temperature = temperature
        self.icon = icon
    }
}
