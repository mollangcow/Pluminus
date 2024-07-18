//
//  TestAPI.swift
//  Pluminus
//
//  Created by kimsangwoo on 7/8/24.
//

import CoreLocation
import SwiftUI
import MapKit

struct TestAPI: View {
    @State private var coordinates: [CLLocationCoordinate2D] = []

    var body: some View {
        MapsView(coordinates: $coordinates)
            .onAppear {
                fetchCountryBorders(for: "대한민국") { result in
                    switch result {
                    case .success(let coords):
                        DispatchQueue.main.async {
                            self.coordinates = coords
                        }
                    case .failure(let error):
                        print("Error fetching borders: \(error)")
                    }
                }
            }
    }
}

struct MapsView: UIViewRepresentable {
    @Binding var coordinates: [CLLocationCoordinate2D]
    
    init(coordinates: Binding<[CLLocationCoordinate2D]>) {
        self._coordinates = coordinates
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        
        if !coordinates.isEmpty {
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polygon)
            
            if let firstCoordinate = coordinates.first {
                let region = MKCoordinateRegion(center: firstCoordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapsView
        
        init(_ parent: MapsView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = .red
                renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

func fetchCountryBorders(for country: String, completion: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
    let query = """
    [out:json];
    rel["admin_level"="2"]["name"="\(country)"];
    out geom;
    """
    let urlString = "http://overpass-api.de/api/interpreter?data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 400, userInfo: nil)))
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let dict = json as? [String: Any],
               let elements = dict["elements"] as? [[String: Any]] {
                
                var coordinates: [CLLocationCoordinate2D] = []
                
                for element in elements {
                    if let geometry = element["geometry"] as? [[String: Double]] {
                        let elementCoordinates = geometry.compactMap { element -> CLLocationCoordinate2D? in
                            guard let lat = element["lat"], let lon = element["lon"] else { return nil }
                            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        }
                        coordinates.append(contentsOf: elementCoordinates)
                    }
                }
                
                // Reduce the number of coordinates if necessary
                if coordinates.count > 1000 {
                    coordinates = Array(coordinates.prefix(1000))
                }
                
                completion(.success(coordinates))
            } else {
                completion(.failure(NSError(domain: "Invalid JSON structure", code: 400, userInfo: nil)))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
