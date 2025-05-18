import Foundation

struct DailyForecast: Codable {
    let date: String
    let tempMin: Double
    let tempMax: Double
    let conditionText: String
    let iconURL: URL?
}
