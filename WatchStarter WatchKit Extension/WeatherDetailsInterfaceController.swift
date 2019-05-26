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

class WeatherDetailsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var intervalLabel: WKInterfaceLabel!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var conditionImage: WKInterfaceImage!
    @IBOutlet weak var conditionLabel: WKInterfaceLabel!
    @IBOutlet weak var feelsLikeLabel: WKInterfaceLabel!
    @IBOutlet weak var windLabel: WKInterfaceLabel!
    @IBOutlet weak var highTemperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var lowTemperatureLabel: WKInterfaceLabel!
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let context = context as? [String: Any], let dataSource = context["dataSource"] as? WeatherDataSource else {
            return
        }
        
        if let index = context["longTermForecastIndex"] as? Int {
            let weather = dataSource.longTermWeather[index]
            
            setTitle(weather.intervalString)
            
            intervalLabel.setHidden(true)
            temperatureLabel.setText(weather.temperatureString)
            conditionLabel.setText(weather.weatherConditionString)
            conditionImage.setImageNamed(weather.weatherConditionImageName)
            feelsLikeLabel.setText(weather.feelTemperatureString)
            windLabel.setText(weather.windString)
            highTemperatureLabel.setText(weather.highTemperatureString)
            lowTemperatureLabel.setText(weather.lowTemperatureString)
        }
        
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

