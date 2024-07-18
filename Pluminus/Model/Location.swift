//
//  Location.swift
//  NC1
//
//  Created by kimsangwoo on 2023/06/01.
//

import CoreLocation

let locationManager = MyLocationManager()

class MyLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    let locationManager = CLLocationManager()
    @Published var currentLocalName: String = "현재 위치 알 수 없음"
    
    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // 위치 정확도
        locationManager.requestWhenInUseAuthorization() // 위치 권한
        locationManager.startUpdatingLocation() // 위치 업데이트 수신
        
        // 위치 기반 지역명 출력
        currentLocalName { placemark in
            if let placemark = placemark, let _ = placemark.country, let _ = placemark.locality {
            } else { }
        }
        
        locationManager.stopUpdatingLocation() // 위치 업데이트 종료
    }
    
    // 현재 위치의 지역명을 알려주는 메서드
    func currentLocalName(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(lastLocation) { (placemarks, error) in
                if let error = error {
                    print("위치 변환 실패: \(error.localizedDescription)")
                    completionHandler(nil)
                    return
                }
                
                if let placemark = placemarks?.first {
                    self.currentLocalName = "\(placemark.locality ?? ""), \(placemark.country ?? "")"
                    completionHandler(placemark)
                } else {
                    print("주소 정보를 찾을 수 없음")
                    completionHandler(nil)
                }
            }
        } else {
            print("위치를 가져올 수 없음")
            completionHandler(nil)
        }
    }
}

func getLocalTime(cityName: String, completion: @escaping (String) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(cityName) { (placemarks, error) in
        guard error == nil else {
            completion("위치를 찾을 수 없습니다.")
            return
        }
        
        if let placemark = placemarks?.first, let timezone = placemark.timeZone {
            let formatter = DateFormatter()
            formatter.timeZone = timezone
            formatter.dateStyle = .long
            formatter.timeStyle = .long
            
            completion(formatter.string(from: Date()))
        } else {
            completion("시간을 불러올 수 없습니다.")
        }
    }
}

class CountriesViewModel: ObservableObject {
    @Published var countries = [CountryModel]()

    func fetchCountries() {
        guard let url = URL(string: "https://countriesnow.space/api/v0.1/countries") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(CountriesData.self, from: data) {
                    DispatchQueue.main.async {
                        self.countries = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct CountryModel: Codable, Identifiable, Hashable {
    var id: UUID
    var country: String
    var cities: [String]

    init(country: String, cities: [String]) {
        self.id = UUID()  // 새로 생성된 UUID
        self.country = country
        self.cities = cities
    }

    // JSON 디코딩 시 id 제외
    private enum CodingKeys: String, CodingKey {
        case country
        case cities
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.country = try container.decode(String.self, forKey: .country)
        self.cities = try container.decode([String].self, forKey: .cities)
        self.id = UUID()  // 새로 생성된 UUID
    }
}

struct CountriesData: Codable {
    var data: [CountryModel]
}
