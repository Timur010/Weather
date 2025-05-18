import Foundation

struct WeatherData: Codable {
    let current: Current
    let locationName: String
    let hourlyForecast: [Hour]
    let dailyForecasts: [DailyForecast]
}
