//
//  WeatherViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 3/26/21.
//  Copyright © 2021 Eduard Minasyan All rights reserved.
//

import UIKit

class WeatherViewModel {
    public var weatherModel: WeatherModel?
    var weatherCompletion: ((WeatherModel) -> ())?
    var model: LocationModel?
    var requestInProgress: Bool = false
    init() {
        if LocationManager.manager.locationModel.value.latitude != nil {
            model = LocationManager.manager.locationModel.value
            if !requestInProgress {
                getWeather()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.model == nil || self.model?.latitude == nil {
                    if let weatherDict = UserDefaults.standard.object(forKey: UserDefaultsKey.weather) as? [String: Any] {
                        self.model = LocationModel(with: weatherDict)
                        self.getWeather()
                    }
                }
            }
            LocationManager.manager.locationModel.bind(listener: { [weak self] (model) in
                guard let strongSelf = self else { return }
                strongSelf.model = model
                if !strongSelf.requestInProgress {
                    self?.getWeather()
                }
            })
        }
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection(_:)), name: NSNotification.Name(rawValue: NotificationName.noInternet), object: nil)
    }
    
    @objc private func handleConnection(_ notification: NSNotification) {
        let isReachable = notification.object as! Int
        if isReachable == 1 && weatherModel == nil {
            getWeather()
        }
    }
    
    func getWeather() {
        let weatherWebService = WeatherWebService()
        guard let model = model else { return }
        if model.latitude == nil || weatherModel != nil {
            return
        }
        requestInProgress = true
        UserDefaults.standard.set(model.getDictionary(), forKey: UserDefaultsKey.weather)
        weatherWebService.getWeather(model) { [weak self] ( response ) in
            guard let strongSelf = self else { return }
            strongSelf.requestInProgress = false
            if let result = response {
                strongSelf.weatherModel = WeatherModel(result)
                strongSelf.weatherModel?.city = model.cityName ?? ""
                strongSelf.weatherCompletion?(strongSelf.weatherModel!)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
