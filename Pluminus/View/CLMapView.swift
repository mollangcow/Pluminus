//
//  CLMapView.swift
//  Pluminus
//
//  Created by kimsangwoo on 6/26/24.
//

import CoreLocation
import MapKit
import SwiftUI

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var pvclLocationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var locationName: String = "Unknown Location"
    private var hasSetInitialLocation = false
    private var geocodeRequestTimer: Timer?
    private var debounceInterval: TimeInterval = 0.5 // Adjust debounce interval as needed
    
    override init() {
        super.init()
        pvclLocationManager.delegate = self
        pvclLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        pvclLocationManager.requestWhenInUseAuthorization()
        pvclLocationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if !hasSetInitialLocation {
            region.center = location.coordinate
            updateLocationName(for: location.coordinate)
            hasSetInitialLocation = true
        }
    }
    
    func updateCenterCoordinate(_ coordinate: CLLocationCoordinate2D) {
        region.center = coordinate
        debounceUpdateLocationName(for: coordinate)
    }
    
    private func debounceUpdateLocationName(for coordinate: CLLocationCoordinate2D) {
        geocodeRequestTimer?.invalidate()
        geocodeRequestTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            self?.updateLocationName(for: coordinate)
        }
    }
    
    private func updateLocationName(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first, error == nil {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                self.locationName = city.isEmpty || country.isEmpty ? "Unknown Location" : "\(city), \(country)"
            } else {
                self.locationName = "Unknown Location"
            }
        }
    }
    
    func isLocationValid() -> Bool {
        return locationName != "Unknown Location" && !locationName.contains("Unknown")
    }
}

struct CLMapView: View {
    @StateObject private var sopvLocationManager = LocationManager()
    @Binding var isShowingCLMapView: Bool
    @Binding var savedLocation: CLLocationCoordinate2D?
    var onSave: ((String) -> Void)? // Callback closure for passing location name
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            
            Map(coordinateRegion: $sopvLocationManager.region, showsUserLocation: true)
                .ignoresSafeArea(edges: .all)
                .onAppear {
                    Pluminus.locationManager.locationManager.requestWhenInUseAuthorization()
                }
                .onChange(of: sopvLocationManager.region.center) { newCenter in
                    sopvLocationManager.updateCenterCoordinate(newCenter)
                }
            
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 30, height: 20)
                .foregroundStyle(Color.black.opacity(0.4))
                .offset(x: 0, y: 0)
            
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(Color.white)
                .offset(x: 0, y: -50)
            
            Image("locationPin")
                .renderingMode(.template)
                .resizable()
                .frame(width: 61, height: 80)
                .foregroundStyle(Color.orange)
                .offset(x: 0, y: -40) // Change offset based on dragging state

            VStack {
                HStack {
                    Spacer()
                    
                    // dismiss button
                    Button {
                        HapticManager.instance.impact(style: .light)
                        dismiss()
                    } label: {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .background(.ultraThickMaterial)
                            .clipShape(Circle())
                            .overlay {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .bold()
                                    .foregroundStyle(.orange)
                                    .frame(width: 14, height: 14)
                            }
                            .frame(width: 32, height: 32)
                            .padding(.all, 20)
                    } //button
                } //HStack
                
                Spacer()
                
                Text(sopvLocationManager.locationName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                
                Button {
                    // Save current location
                    savedLocation = sopvLocationManager.region.center
                    onSave?(sopvLocationManager.locationName) // 위치 이름과 시간대 오프셋을 전달
                } label: {
                    Text("Save")
                        .font(.title2)
                        .frame(width: screenWidth * 0.8, height: 70)
                        .background(sopvLocationManager.isLocationValid() ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(35)
                }
                .padding(.bottom, 40)
                .disabled(!sopvLocationManager.isLocationValid())
            } //VStack
        } //ZStack
        .ignoresSafeArea()
    } //body
} //struct
