import Foundation
import CoreLocation

enum LocationError: Error {
    case permissionDenied
    case timeout
    case unknown
}

protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(latitude: Double, longitude: Double)
    func didFailWithLocation(error: Error)
}

final class LocationService: NSObject, LocationServiceProtocol {
    weak var delegate: LocationServiceDelegate?

    private let locationManager = CLLocationManager()
    private let locationCache: LocationCache
    private var locationTimeoutTimer: Timer?

    init(locationCache: LocationCache = UserDefaultsLocationCache()) {
        self.locationCache = locationCache
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            delegate?.didFailWithLocation(error: LocationError.permissionDenied)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            startTimeout()
        @unknown default:
            delegate?.didFailWithLocation(error: LocationError.unknown)
        }
    }

    func getCachedLocation() -> CLLocationCoordinate2D? {
        return locationCache.getLastLocation()
    }

    private func startTimeout() {
        locationTimeoutTimer?.invalidate()
        locationTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.locationManager.stopUpdatingLocation()
            self.delegate?.didFailWithLocation(error: LocationError.timeout)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationTimeoutTimer?.invalidate()

        guard let location = locations.last else {
            delegate?.didFailWithLocation(error: LocationError.unknown)
            return
        }

        locationCache.saveLastLocation(location)
        delegate?.didUpdateLocation(latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationTimeoutTimer?.invalidate()
        delegate?.didFailWithLocation(error: error)
    }
}
