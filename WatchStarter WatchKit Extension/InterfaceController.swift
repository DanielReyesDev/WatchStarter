/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var feelsLikeLabel: WKInterfaceLabel!
    @IBOutlet weak var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet weak var conditionsImage: WKInterfaceImage!
    
    @IBOutlet weak var forecast1Label: WKInterfaceLabel!
    @IBOutlet weak var forecast2Label: WKInterfaceLabel!
    @IBOutlet weak var forecast3Label: WKInterfaceLabel!
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    lazy var dataSource: WeatherDataSource = {
        let measurementSystem = UserDefaults.standard.string(forKey: "measurementSystem") ?? "Metric"
        if measurementSystem == "Metric" {
            return WeatherDataSource(measurementSystem: .Metric)
        }
        return WeatherDataSource(measurementSystem: .USCustomary)
    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        updateAllForecasts()
    }
    
    func updateAllForecasts() {
        updateCurrentForecaset()
        updateShortTermForecast()
        updateLongTermForecast()
    }
    
    // Main section of the WatchApp
    func updateCurrentForecaset() {
        let weather = dataSource.currentWeather
        temperatureLabel.setText(weather.temperatureString)
        feelsLikeLabel.setText(weather.feelTemperatureString)
        windSpeedLabel.setText(weather.windString)
        conditionsImage.setImageNamed(weather.weatherConditionImageName)
    }
    
    // 3-Segmented section of the WatchApp
    func updateShortTermForecast() {
        let labels = [forecast1Label, forecast2Label, forecast3Label]
        let weatherData = [dataSource.shortTermWeather[0], dataSource.shortTermWeather[dataSource.shortTermWeather.count/2], dataSource.shortTermWeather[dataSource.shortTermWeather.count-1]]
        
        for i in 0...2 {
            let label = labels[i]
            let weather = weatherData[i]
            label?.setText("\(weather.intervalString)\n\(weather.temperatureString)")
        }
        
    }
    
    // Table at the bottom on the WatchApp
    func updateLongTermForecast() {
        table.setNumberOfRows(dataSource.longTermWeather.count, withRowType: "ForecastRow")
        
        for (i, weather) in dataSource.longTermWeather.enumerated() {
            if let row = table.rowController(at: i) as? ForecastRowController {
                row.dayLabel.setText(weather.intervalString)
                row.temperatureLabel.setText(weather.temperatureString)
                row.conditionsLabel.setText(weather.weatherConditionString)
                row.conditionsImage.setImageNamed(weather.weatherConditionImageName)
            }
        }
    }
    
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        print("Identifier: \(segueIdentifier)")
        if segueIdentifier == "WeatherDetailsSegue" {
            let context = [
                "dataSource": dataSource,
                "longTermForecastIndex": rowIndex
            ] as [String : Any]
            print(context)
            return context
        }
        return nil
    }
    
    
    @IBAction func switchToMetric() {
        dataSource = WeatherDataSource.init(measurementSystem: .Metric)
        UserDefaults.standard.set("Metric", forKey: "measurementSystem")
        updateAllForecasts()
    }
    
    @IBAction func switchToUSCustomary() {
        dataSource = WeatherDataSource.init(measurementSystem: .USCustomary)
        UserDefaults.standard.set("USCustomary", forKey: "measurementSystem")
        updateAllForecasts()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
