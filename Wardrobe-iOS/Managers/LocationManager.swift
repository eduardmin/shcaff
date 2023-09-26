//
//  LocationManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/10/20.
//

import UIKit
import CoreLocation

struct LocationModel {
    var latitude: Double?
    var longitude: Double?
    var cityName: String?
    init() {
        
    }
    
    init(latitude: Double?, longitude: Double?, cityName: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
    }
    
    init(with dict: [String: Any]) {
        latitude = dict["latitude"] as? Double
        longitude = dict["longitude"] as? Double
        cityName = dict["cityName"] as? String
    }
    
    func getDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["latitude"] = latitude
        dict["longitude"] = latitude
        dict["cityName"] = cityName
        return dict
    }
}

class LocationManager: NSObject {
    static let manager = LocationManager()
    private var locationManager: CLLocationManager =  CLLocationManager()
    private var location: CLLocation? {
        didSet {
            location?.fetchCity { city, error in
                guard let city = city, error == nil else { return }
                self.locationModel.value = LocationModel(latitude: self.location!.coordinate.latitude, longitude: self.location!.coordinate.longitude, cityName: city)
            }
        }
    }
    var locationModel: Observable<LocationModel> = Observable(LocationModel())
    var error: Observable<Error?> = Observable(nil)
    override init() {
        super.init()        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.distanceFilter = 0.1
        locationManager.delegate = self
    }
}

//MARK:- CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error.value = error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.location = location
        stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            break
        default:
            break
        }
        
    }
}

//MARK:- Public func
extension LocationManager {
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func requestForAutorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }
}

extension CLLocation {
    func fetchCity(completion: @escaping (_ city: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self, preferredLocale: Locale(identifier: "en-EN")){
            completion($0?.first?.locality, $1)
        }
    }
}
