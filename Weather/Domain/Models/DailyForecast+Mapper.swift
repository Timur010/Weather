import Foundation

extension DailyForecast {
    init(from dto: ForecastDay) {
        self.date = dto.date
        self.tempMin = dto.day.mintempC
        self.tempMax = dto.day.maxtempC
        self.conditionText = dto.day.condition.text
        self.iconURL = URL(string: "https:\(dto.day.condition.icon)")
    }
}
