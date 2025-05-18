import Foundation


struct WeatherCurrentResponse: Codable {
    let location: Location
    let current: Current
}

struct WeatherForecastResponse: Codable {
    let location: Location
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct Current: Codable {
    let tempC: Double
    let condition: Condition
    let windKph: Double
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition, windKph = "wind_kph", humidity
    }
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let hour: [Hour]
    let day: Day
}

struct Day: Codable {
    let avgtempC: Double
    let maxtempC: Double
    let mintempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case avgtempC = "avgtemp_c"
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}

struct Hour: Codable {
    let time: String
    let tempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
    }
}

struct Condition: Codable {
    let text: String
    let icon: String
}
