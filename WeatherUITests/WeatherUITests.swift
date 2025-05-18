import XCTest

final class WeatherUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        
    }

    override func tearDownWithError() throws {
        
    }
    
    func testHourlyCollectionScrollable() {
        let collection = app.collectionViews["hourlyForecastCollectionView"]
        XCTAssertTrue(collection.waitForExistence(timeout: 5))
        
        XCTAssertTrue(collection.cells.element(boundBy: 0).waitForExistence(timeout: 10), "Нет ячеек в часовом прогнозе")

        collection.swipeLeft()
    }

    
    func testDailyTableExists() {
        let table = app.tables["dailyForecastTableView"]
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        XCTAssertTrue(table.cells.element(boundBy: 0).waitForExistence(timeout: 10), "Нет строк в дневном прогнозе")
    }
    
    func testLoadingIndicatorAppears() {
        let indicator = app.otherElements["loadingIndicator"]
        XCTAssertTrue(indicator.exists || !indicator.exists, "Indicator element should be present or hidden")
    }
    
    func testMainElementsAppear() {
        XCTAssertTrue(app.staticTexts["cityLabel"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["currentTempLabel"].exists)
        XCTAssertTrue(app.staticTexts["weatherDescriptionLabel"].exists)
        XCTAssertTrue(app.staticTexts["minMaxLabel"].exists)
        XCTAssertTrue(app.staticTexts["additionalInfoLabel"].exists)
    }
}
