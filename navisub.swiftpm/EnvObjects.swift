//
//  Env.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/16.
//

import SwiftUI
import MapKit
import CoreLocation

@available(iOS 17.0, *)
class EnvObjects: ObservableObject{
    @Published var selectedLine: Line? = nil
    @Published var selectedStation: Station? = nil
    @Published var selectedStart: Station? = nil
    @Published var selectedEnd: Station? = nil
    @Published var selectedDir: Character = "S"
    @Published var showHelp: Bool = true
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9180, longitude: 116.3960),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    ))
    @Published var path = NavigationPath()
    
    init() {
        
    }
    
    public func setStart(station: Station) {
        if (selectedEnd == station) {
            selectedEnd = nil
        }
        selectedStart = station
    }
    
    public func setEnd(station: Station ) {
        if (selectedStart == station) {
            selectedStart = nil
        }
        selectedEnd = station
    }
}
