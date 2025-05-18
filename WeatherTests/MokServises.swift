import Foundation
import CoreLocation
@testable import Weather

final class LocationServiceMock: LocationServiceProtocol {
    weak var delegate: LocationServiceDelegate?
    var mockLocation: (lat: Double, lon: Double)?

    func getCachedLocation() -> CLLocationCoordinate2D? { return nil }
    func requestLocation() { }

    func simulateLocationUpdate() {
        if let loc = mockLocation {
            delegate?.didUpdateLocation(latitude: loc.lat, longitude: loc.lon)
        }
    }

    func simulateLocationFailure(error: Error) {
        delegate?.didFailWithLocation(error: error)
    }
}

final class FetchWeatherUseCaseMock: FetchWeatherUseCaseProtocol {
    func execute(lat: Double, lon: Double, completion: @escaping (Result<Weather.WeatherData, any Error>) -> Void) {
        if let result = mockResult {
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    var mockResult: Result<(WeatherData), Error>?

}

final class WeatherViewModelDelegateMock: WeatherViewModelDelegate {
    var didUpdateWeatherHandler: (() -> Void)?
    var didFailWithErrorHandler: ((Error) -> Void)?

    func didUpdateWeather() {
        didUpdateWeatherHandler?()
    }

    func didFailWithError(_ error: Error) {
        didFailWithErrorHandler?(error)
    }

    func didStartLoading() { }
    func didFinishLoading() { }
}

extension WeatherData {
    static var mock: WeatherData {
        return WeatherData(
            current: Current (
                tempC: 20.5,
                condition: Condition(
                    text: "Ясно",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
                ),
                windKph: 10.0,
                humidity: 55
            ),
            locationName: "Москва",
            hourlyForecast: (0..<24).map { hour in
                Hour(
                    time: String(format: "2025-05-16 %02d:00", hour),
                    tempC: Double(16 + hour % 10),
                    condition: Condition(
                        text: "Солнечно",
                        icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
                    )
                )
            },
            dailyForecasts: (0..<24).map { _ in
                DailyForecast(
                    date: "2025-05-16",
                    tempMin: 21.0,
                    tempMax: 25.0,
                    conditionText: "Солнечно",
                    iconURL: URL(string: "//cdn.weatherapi.com/weather/64x64/day/113.png")
                )
            }
        )
    }
}
