import Foundation
import CoreLocation

protocol LocationCache {
    func saveLastLocation(_ location: CLLocation)
    func getLastLocation() -> CLLocationCoordinate2D?
}

class UserDefaultsLocationCache: LocationCache {
    private let defaults = UserDefaults.standard

    func saveLastLocation(_ location: CLLocation) {
        defaults.set(location.coordinate.latitude, forKey: "lastLat")
        defaults.set(location.coordinate.longitude, forKey: "lastLon")
    }

    func getLastLocation() -> CLLocationCoordinate2D? {
        let lat = defaults.double(forKey: "lastLat")
        let lon = defaults.double(forKey: "lastLon")
        if lat == 0 && lon == 0 { return nil } 
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
