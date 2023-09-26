//
//  WeatherModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/11/20.
//

import UIKit

class WeatherModel {
    var city: String = ""
    let icon: String
    let kelvinTemp: Double
    let date: Double
    
    var tempCelsius: String {
        if let celsius = UIApplication.appDelegate.profileModel?.celsius, celsius{
            let celsiusTemp = kelvinTemp - 273.15
            return String(format: "%.0f", celsiusTemp) + "C".localize()
        } else {
            let fahrenheitTemp = 1.8 * (kelvinTemp - 273) + 32
            return String(format: "%.0f", fahrenheitTemp) + "°F".localize()
        }
    }
    
    init(_ json: [String: Any]) {
        icon = json["icon"] as? String ?? ""
        kelvinTemp = json["temp"] as? Double ?? 0
        date = json["date"] as? Double ?? 0
    }
}
