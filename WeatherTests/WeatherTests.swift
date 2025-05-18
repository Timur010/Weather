import XCTest
import CoreLocation
@testable import Weather

final class WeatherViewModelTests: XCTestCase {

    private var viewModel: WeatherViewModel!
    private var locationServiceMock: LocationServiceMock!
    private var useCaseMock: FetchWeatherUseCaseMock!
    private var delegateMock: WeatherViewModelDelegateMock!

    override func setUp() {
        super.setUp()
        locationServiceMock = LocationServiceMock()
        useCaseMock = FetchWeatherUseCaseMock()
        viewModel = WeatherViewModel(locationService: locationServiceMock, getWeatherUseCase: useCaseMock)
        delegateMock = WeatherViewModelDelegateMock()
        viewModel.delegate = delegateMock
    }

    func testLoadWeather_Success() {
        useCaseMock.mockResult = .success((.mock))
        locationServiceMock.mockLocation = (lat: 55.75, lon: 37.62)

        let expectation = expectation(description: "Weather loaded successfully")

        delegateMock.didUpdateWeatherHandler = {
            XCTAssertEqual(self.viewModel.locationName, "Москва")
            XCTAssertEqual(self.viewModel.temperatureText, "\(Int(WeatherData.mock.current.tempC))°")
            expectation.fulfill()
        }

        viewModel.loadWeather()
        locationServiceMock.simulateLocationUpdate()

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadWeather_WeatherFetchFailure() {
        useCaseMock.mockResult = .failure(ServiceError.noData)
        locationServiceMock.mockLocation = (lat: 55.75, lon: 37.62)

        let expectation = expectation(description: "Weather load failure handled")

        delegateMock.didFailWithErrorHandler = { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        viewModel.loadWeather()
        locationServiceMock.simulateLocationUpdate()

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadWeather_LocationFailure() {
        let expectation = expectation(description: "Location failure handled")

        delegateMock.didFailWithErrorHandler = { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        viewModel.loadWeather()
        locationServiceMock.simulateLocationFailure(error: ServiceError.unknown)

        wait(for: [expectation], timeout: 1.0)
    }
}
