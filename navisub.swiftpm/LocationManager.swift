//  NavigationPath.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/16.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
  @Published var currentLocation: CLLocationCoordinate2D?
  public var locManager = CLLocationManager()
  func checkLocationAuthorization() {
    locManager.delegate = self
    let authorizationStatus = locManager.authorizationStatus


    DispatchQueue.global().async { [weak self] in
      if CLLocationManager.locationServicesEnabled() {
        DispatchQueue.main.async {
          if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            self?.locManager.startUpdatingLocation()
          }
          else if authorizationStatus == .notDetermined {
              self?.locManager.requestWhenInUseAuthorization()
          }
          else {
              self?.locManager.stopUpdatingLocation()
          }
        }
      }
      else {
        DispatchQueue.main.async {
          if authorizationStatus == .notDetermined {
            self?.locManager.requestWhenInUseAuthorization()
          }
          else {
            self?.locManager.stopUpdatingLocation()
          }
        }
      }
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let newLocation = manager.location, !(newLocation.coordinate.longitude == 0.0 && newLocation.coordinate.latitude == 0.0) {
      currentLocation = newLocation.coordinate
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    currentLocation = nil
    locManager.delegate = nil
    locManager.stopUpdatingLocation()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .denied {
      locManager.stopUpdatingLocation()
    }
    else if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
      locManager.startUpdatingLocation()
    }
  }
}
