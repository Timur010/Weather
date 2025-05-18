import Foundation

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeather()
    func didFailWithError(_ error: Error)
    func didStartLoading()
    func didFinishLoading()
}

final class WeatherViewModel {

    weak var delegate: WeatherViewModelDelegate? {
        didSet { loadWeather() }
    }

    private var locationService: LocationServiceProtocol
    private let getWeatherUseCase: FetchWeatherUseCaseProtocol

    private(set) var currentWeather: Current?
    private(set) var locationName: String = ""
    private(set) var hourlyForecast: [Hour] = []
    private(set) var dailyForecasts: [DailyForecast] = []
    private(set) var minWeekTemp: Double = 0
    private(set) var maxWeekTemp: Double = 0

    var locationTitle: String {
        return locationName
    }

    var temperatureText: String {
        guard let current = currentWeather else { return "—" }
        return "\(Int(current.tempC))°"
    }

    var conditionText: String {
        return currentWeather?.condition.text ?? "—"
    }

    var minMaxTemperatureText: String {
        guard let today = dailyForecasts.first else { return "—" }
        let max = Int(today.tempMax)
        let min = Int(today.tempMin)
        return "Макс: \(max)°  Мин: \(min)°"
    }

    var additionalDescriptionText: String {
        guard let weather = currentWeather else { return "—" }
        return "ветер - \(Int(weather.windKph)) км/ч   влажность - \(weather.humidity)%"
    }

    init(locationService: LocationServiceProtocol,
         getWeatherUseCase: FetchWeatherUseCaseProtocol) {
        self.locationService = locationService
        self.getWeatherUseCase = getWeatherUseCase
        self.locationService.delegate = self
    }

    func loadWeather() {
        delegate?.didStartLoading()
        locationService.requestLocation()
    }

    private func fetchWeather(lat: Double, lon: Double) {
        getWeatherUseCase.execute(lat: lat, lon: lon) { [weak self] result in
            guard let self else { return }

            self.delegate?.didFinishLoading()

            switch result {
            case let .success(data):
                self.handleWeatherData(data)
                self.delegate?.didUpdateWeather()

            case let .failure(error):
                self.delegate?.didFailWithError(error)
            }
        }
    }

    private func handleWeatherData(_ data: WeatherData) {
        self.currentWeather = data.current
        self.locationName = data.locationName
        self.hourlyForecast = data.hourlyForecast
        self.dailyForecasts = data.dailyForecasts
        self.minWeekTemp = data.dailyForecasts.map { $0.tempMin }.min() ?? 0
        self.maxWeekTemp = data.dailyForecasts.map { $0.tempMax }.max() ?? 0
    }
}

extension WeatherViewModel: LocationServiceDelegate {
    func didUpdateLocation(latitude: Double, longitude: Double) {
        fetchWeather(lat: latitude, lon: longitude)
    }

    func didFailWithLocation(error: Error) {
        delegate?.didFinishLoading()

        if let last = locationService.getCachedLocation() {
            fetchWeather(lat: last.latitude, lon: last.longitude)
        } else {
            let fallback = (lat: 55.7558, lon: 37.6173)
            fetchWeather(lat: fallback.lat, lon: fallback.lon)
        }
        delegate?.didFailWithError(error)
    }
}

