import CoreLocation
import Foundation

final class DIContainer {
    static let shared = DIContainer()

    private init() {}

    lazy var weatherService: WeatherServiceProtocol = WeatherService()
    lazy var weatherCache: WeatherCache = UserDefaultsWeatherCache()
    lazy var locationCache: LocationCache = UserDefaultsLocationCache()

    lazy var locationService: LocationServiceProtocol = LocationService(locationCache: locationCache)

    lazy var weatherRepository: WeatherRepositoryProtocol = WeatherRepository(
        weatherService: weatherService,
        cache: weatherCache
    )

    lazy var getWeatherUseCase: FetchWeatherUseCaseProtocol = FetchWeatherUseCase(
        repository: weatherRepository
    )

    func makeWeatherViewModel() -> WeatherViewModel {
        return WeatherViewModel(
            locationService: locationService,
            getWeatherUseCase: getWeatherUseCase
        )
    }
}
