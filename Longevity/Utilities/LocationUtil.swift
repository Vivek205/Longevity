//
//  LocationUtil.swift
//  Longevity
//
//  Created by vivek on 06/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationUtil: NSObject {
    static let shared = LocationUtil()
    private let locationManager = CLLocationManager()

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()

            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
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
            AppSyncManager.instance.updateHealthProfile(location: locationDetails)
        }
    }
}
