import Foundation

protocol FetchWeatherUseCaseProtocol {
    func execute(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> Void)
}

final class FetchWeatherUseCase: FetchWeatherUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        repository.fetchWeatherData(lat: lat, lon: lon, completion: completion)
    }
}
