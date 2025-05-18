import Foundation

final class WeatherRepository: WeatherRepositoryProtocol {
    private let weatherService: WeatherServiceProtocol
    private let cache: WeatherCache

    init(weatherService: WeatherServiceProtocol, cache: WeatherCache) {
        self.weatherService = weatherService
        self.cache = cache
    }

    func fetchWeatherData(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        if !NetworkMonitor.shared.isConnected {
            if let cached = try? cache.getCachedWeather() {
                completion(.success(cached))
            } else {
                completion(.failure(ServiceError.noData))
            }
            return
        }

        let group = DispatchGroup()
        var current: WeatherCurrentResponse?
        var forecast: WeatherForecastResponse?
        var fetchError: Error?

        group.enter()
        weatherService.fetchCurrentWeather(lat: lat, lon: lon) { result in
            switch result {
            case .success(let data): current = data
            case .failure(let error): fetchError = error
            }
            group.leave()
        }

        group.enter()
        weatherService.fetchForecast(lat: lat, lon: lon) { result in
            switch result {
            case .success(let data): forecast = data
            case .failure(let error): fetchError = error
            }
            group.leave()
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            guard let current = current, let forecast = forecast else {
                DispatchQueue.main.async {
                    completion(.failure(fetchError ?? ServiceError.unknown))
                }
                return
            }

            let locationName = current.location.name
            let hourly = Self.extractHourly(from: forecast)
            let daily = forecast.forecast.forecastday.map { DailyForecast(from: $0) }

            let weatherData = WeatherData(
                current: current.current,
                locationName: locationName,
                hourlyForecast: hourly,
                dailyForecasts: daily
            )

            try? self.cache.saveWeather(weatherData)

            DispatchQueue.main.async {
                completion(.success(weatherData))
            }
        }

    }

    private static func extractHourly(from forecast: WeatherForecastResponse) -> [Hour] {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        guard let today = forecast.forecast.forecastday.first else { return [] }

        let todayHours = today.hour.filter {
            guard let date = formatter.date(from: $0.time) else { return false }
            return date > now
        }

        let tomorrowHours = forecast.forecast.forecastday.dropFirst().first?.hour ?? []

        return todayHours + tomorrowHours
    }
}
