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
import CoreGraphics


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var feelsLikeLabel: WKInterfaceLabel!
    @IBOutlet weak var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet weak var conditionsImage: WKInterfaceImage!
    
    @IBOutlet weak var shortTermForecastGroup: WKInterfaceGroup!
    @IBOutlet weak var forecast1Button: WKInterfaceButton!
    @IBOutlet weak var forecast2Button: WKInterfaceButton!
    @IBOutlet weak var forecast3Button: WKInterfaceButton!
    
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
        drawShortTermForecastGraph()
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
        let labels = [forecast1Button, forecast2Button, forecast3Button]
        let weatherData = [dataSource.shortTermWeather[0], dataSource.shortTermWeather[dataSource.shortTermWeather.count/2], dataSource.shortTermWeather[dataSource.shortTermWeather.count-1]]
        
        for i in 0...2 {
            let button = labels[i]
            let weather = weatherData[i]
            button?.setTitle("\(weather.intervalString)\n\(weather.temperatureString)")
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
    
    @IBAction func showForecast1() {
        showShortTermForecast(for: 0)
    }
    
    @IBAction func showForecast2() {
        showShortTermForecast(for: 1)
    }
    
    @IBAction func showForecast3() {
        showShortTermForecast(for: 2)
    }
    
    let detailsKey = "WeatherDetailsInterface"
    
    // To show the modal WKInterfaceController with 3 pages
    func showShortTermForecast(for index: Int) {
        
        let context1: AnyObject = ["dataSource": dataSource, "shortTermForecastIndex": 0] as AnyObject
        let context2: AnyObject = ["dataSource": dataSource, "shortTermForecastIndex": dataSource.shortTermWeather.count/2] as AnyObject
        let context3: AnyObject = ["dataSource": dataSource, "shortTermForecastIndex": dataSource.shortTermWeather.count - 1]  as AnyObject
        
        let contexts = [(name: detailsKey, context: context1),
                        (name: detailsKey, context: context2),
                        (name: detailsKey, context: context3)]
        
        presentController(withNamesAndContexts: contexts)
    }
    
    // Drawing with CoreGraphics
    func drawShortTermForecastGraph() {
        let temperatures = dataSource.shortTermWeather.map { CGFloat($0.temperature) }
        let graphicWidth: CGFloat = 312
        let graphicHeight: CGFloat = 88
        
        // Setting up the Canvas for the drawing (fixed size of 42mm Apple Watch)
        UIGraphicsBeginImageContext(CGSize(width: graphicWidth, height: graphicHeight))
        
        // Grabbing the reference of the current contexct
        let context = UIGraphicsGetCurrentContext()
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Drawing...
//        let path = UIBezierPath()
//        path.lineWidth = 4
//        UIColor.green.withAlphaComponent(0.33).setStroke()
//
//        path.move(to: CGPoint.init(x: 0, y: temperatures[0]))
//        path.addLine(to: CGPoint.init(x: graphicWidth/2, y: graphicHeight - temperatures[temperatures.count/2]))
//        path.addLine(to: CGPoint.init(x: graphicWidth, y: graphicHeight - temperatures[temperatures.count - 1]))
//
//        path.stroke()
        
        
        let path = UIBezierPath()
        path.lineWidth = 4
        UIColor.green.withAlphaComponent(0.33).setStroke()
        
        guard let maxTemperature = temperatures.max(),
              let minTemperature = temperatures.min() else {
            return
        }
        let temperatureSpread = maxTemperature - minTemperature
        
        func xCoordinateForIndex(index: Int) -> CGFloat {
            return graphicWidth * CGFloat(index) / CGFloat(temperatures.count - 1)
        }
        func yCoordinateForTemperature(temperature: CGFloat) -> CGFloat {
            return graphicHeight - (graphicHeight * (temperature - minTemperature) / temperatureSpread)
        }
        
        path.move(to: CGPoint(x: 0, y: yCoordinateForTemperature(temperature: temperatures[0])))
        
        for (i, temperature) in temperatures.enumerated() {
            let x: CGFloat = xCoordinateForIndex(index: i)
            let y: CGFloat = yCoordinateForTemperature(temperature: temperature)
            
            print("\(i) (\(x), \(y))")
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.stroke()
        // end drawing code
        
        // Setting the created image as a backgorund of the Group
        if let cgImage = context?.makeImage() {
            let backgroundImage = UIImage(cgImage: cgImage)
            shortTermForecastGroup.setBackgroundImage(backgroundImage)
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
