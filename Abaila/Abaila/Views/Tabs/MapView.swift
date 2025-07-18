//
//  MapView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/27/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(LocationManager.self) var locationManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onAppear {
            updateCameraPosition()
        }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
            if newValue != nil {
                updateCameraPosition()
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
    }
    
    func updateCameraPosition() {
        if let userLocation = locationManager.userLocation {
            let userRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
            withAnimation {
                cameraPosition = .region(userRegion)
            }
        }
    }
}
