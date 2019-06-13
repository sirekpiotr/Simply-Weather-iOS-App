//
//  HourForecast.swift
//  Weather
//
//  Created by Piotr Sirek on 01/11/2018.
//  Copyright © 2018 Piotr Sirek. All rights reserved.
//

import Foundation

class HourForecast {
    var hour = Int()
    var temperature = Int()
    var icon = String()
    
    init(hour: Int, temperature: Int, icon: String) {
        self.hour = hour
        self.temperature = temperature
        self.icon = icon
    }
}
