import Foundation

final class WeatherService {
    private let session: URLSession
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherCurrentResponse, Error>) -> Void) {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(lat),\(lon)&lang=ru"
        fetch(urlString: urlString, completion: completion)
    }
    
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<WeatherForecastResponse, Error>) -> Void) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3&lang=ru"
        fetch(urlString: urlString, completion: completion)
    }
    
    private func fetch<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(ServiceError.networkError(error)))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ServiceError.noData))
                }
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(ServiceError.decodingError(error)))
                    }
                }
            }
        }.resume()

    }

    
}

extension WeatherService: WeatherServiceProtocol {}


enum ServiceError: LocalizedError {
    case invalidURL
    case noData
    case networkError(Error)
    case decodingError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
        case .noData:
            return "Данные не получены"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Ошибка обработки данных: \(error.localizedDescription)"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}
