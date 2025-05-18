import Foundation

protocol WeatherCache {
    func getCachedWeather() throws -> WeatherData?
    func saveWeather(_ weather: WeatherData) throws
}

final class UserDefaultsWeatherCache: WeatherCache {
    private let weatherKey = "cachedWeatherData"
    private let defaults = UserDefaults.standard

    func getCachedWeather() throws -> WeatherData? {
        guard
            let data = defaults.data(forKey: weatherKey),
            let weather = try? JSONDecoder().decode(WeatherData.self, from: data)
        else {
            return nil
        }
        return weather
    }

    func saveWeather(_ weather: WeatherData) throws {
        let data = try JSONEncoder().encode(weather)
        defaults.set(data, forKey: weatherKey)
    }
}
