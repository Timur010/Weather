import CoreLocation

protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    func requestLocation()
    func getCachedLocation() -> CLLocationCoordinate2D?
}
