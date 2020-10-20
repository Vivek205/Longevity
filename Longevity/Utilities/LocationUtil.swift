//
//  LocationUtil.swift
//  Longevity
//
//  Created by vivek on 06/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationDetails: Codable {
    var latitude: String?
    var longitude: String?
    var zipcode: String?
    var state: String?
    var city: String?
    var country: String?
}

enum LocationError:Error {
    case accessDenied
    case accesNotDetermined
}

final class LocationUtil: NSObject {
    static let shared = LocationUtil()
    private let locationManager = CLLocationManager()
    var currentLocation:DynamicValue<LocationDetails>

    var locationJsonString: String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(currentLocation.value) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    override init() {
        self.currentLocation = DynamicValue(LocationDetails())
        super.init()
        locationManager.delegate = self
    }


    func lookUpCurrentLocation(completionHandler: ((CLPlacemark?)-> Void)? = nil ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()

            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler?(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler?(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler?(nil)
        }
    }

    func getCurrentLocation(completion:((Error?)->Void)?) {
        self.locationManager.requestWhenInUseAuthorization()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied ||  authorizationStatus == .restricted {
            completion?(LocationError.accessDenied)
            return
        }
        if authorizationStatus == .notDetermined {
            completion?(LocationError.accesNotDetermined)
            return
        }

        if(authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways) {
            self.lookUpCurrentLocation()
            completion?(nil)
             }
    }

    func updateLocation() {
        self.lookUpCurrentLocation { (placemark) in
            var locationDetails = LocationDetails()
            if let latitude = placemark?.location?.coordinate.latitude,
               let longitude = placemark?.location?.coordinate.longitude,
               let city = placemark?.locality,
               let state = placemark?.administrativeArea,
               let country = placemark?.country {
                locationDetails.latitude = "\(latitude)"
                locationDetails.longitude = "\(longitude)"
                locationDetails.city = "\(city)"
                locationDetails.state = "\(state)"
                locationDetails.country = "\(country)"
            }
            if let postalCode = placemark?.postalCode {
                locationDetails.zipcode = "\(postalCode)"
            }
            self.currentLocation.value = locationDetails
//            AppSyncManager.instance.updateHealthProfile(location: locationDetails)
        }
    }

    func saveLocation(json: String) -> LocationDetails? {
        guard !json.isEmpty else { return nil}
        let decoder = JSONDecoder()
        let data = Data(json.utf8)
        guard let value = try? decoder.decode(LocationDetails.self, from: data) else { return nil }
        self.currentLocation.value = value
        return value
    }
}

extension LocationUtil:CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        print(authorizationStatus)
        if !(authorizationStatus == .denied || authorizationStatus == .notDetermined || authorizationStatus == .restricted) {
            self.updateLocation()
        }
    }
}
