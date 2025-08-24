import SwiftUI
import MapKit

struct MapView: View {
    @Environment(LocationManager.self) var locationManager
//    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var alertManager: AlertManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedAlert: AlertResponse?
    init(authViewModel: AuthViewModel) {
//        self._selectedAlert = selectedAlert
        self._alertManager = StateObject(wrappedValue: AlertManager(authViewModel: authViewModel))
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            // Add alert annotations
            ForEach(alertManager.alerts) { alert in
                if let location = alert.location {
                    Annotation(
                        alert.title,
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.coordinates[1],
                            longitude: location.coordinates[0]
                        )
                    ) {
                        AlertMapPin(alert: alert)
                            .onTapGesture {
                                selectedAlert = alert
                            }
                    }
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onAppear {
            updateCameraPosition()
            Task {
                await alertManager.fetchAlerts()
            }
        }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
            if newValue != nil {
                updateCameraPosition()
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        .refreshable {
            await alertManager.fetchAlerts()
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
