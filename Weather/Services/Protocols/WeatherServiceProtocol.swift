protocol WeatherServiceProtocol: AnyObject {
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherCurrentResponse, Error>) -> Void)
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<WeatherForecastResponse, Error>) -> Void)
}
