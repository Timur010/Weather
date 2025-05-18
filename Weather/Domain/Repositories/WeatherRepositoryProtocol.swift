import Foundation

protocol WeatherRepositoryProtocol {
    func fetchWeatherData(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> Void)
}
