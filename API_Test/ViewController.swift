//
//  ViewController.swift
//  API_Test
//
//  Created by Michael Whinfrey on 6/26/19.
//  Copyright © 2019 Michael Whinfrey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var holdArray: [String] = []

    // Set up general IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    
    // Set up El Porto IBOutlets
    @IBOutlet weak var portoSizeLabel: UILabel!
    @IBOutlet weak var portoSpotLabel: UILabel!
    @IBOutlet weak var portoShapeLabel: UILabel!
    @IBOutlet weak var portoConditionsView: UIView!
    
    // Set up PV Cove IBOutlets
    
    @IBOutlet weak var pvCoveSizeLabel: UILabel!
    @IBOutlet weak var pvCoveSpotLabel: UILabel!
    @IBOutlet weak var pvCoveShapeLabel: UILabel!
    @IBOutlet weak var pvCoveConditionsView: UIView!
    
    // Set up Hermosa Beach IBOutlets
    @IBOutlet weak var hermosaSizeLabel: UILabel!
    @IBOutlet weak var hermosaSpotLabel: UILabel!
    @IBOutlet weak var hermosaShapeLabel: UILabel!
    @IBOutlet weak var hermosaConditionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeRequest("http://api.spitcast.com/api/spot/forecast/402/") // El Porto
        makeRequest("http://api.spitcast.com/api/spot/forecast/633/") // PV Cove
        makeRequest("http://api.spitcast.com/api/spot/forecast/202/") // Hermosa Beach
    }
    
    func makeRequest(_ urlString: String) {
        
        let surfURL = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: surfURL, completionHandler: { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                
                let dateArray = self.getDate()
                
                let dateString = dateArray[0]
                
                let hourString = dateArray[2]
                
                guard let spotName = jsonArray[8]["spot_name"] as? String else { return }
                
                guard let waveSize = jsonArray[8]["size"] as? Int else { return }
                
                let sizeString = String(waveSize) + " ft"
                
                guard let waveShape = jsonArray[8]["shape_full"] as? String else { return }
                
                self.holdArray.append(dateString)
                self.holdArray.append(hourString)
                self.holdArray.append(spotName)
                self.holdArray.append(String(waveSize))
                self.holdArray.append(sizeString)
                self.holdArray.append(waveShape)
                
                DispatchQueue.main.async {
                    self.refreshPage()
                }
            }
            catch let parsingError {
                print("Error", parsingError)
            }
        })
        task.resume()
    }
    
    func pickColor(size: Int) -> UIColor {
        
        let lightRed = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 0.4)
        let lightYellow = UIColor(displayP3Red: 1.0, green: 1.0, blue: 0.0, alpha: 0.4)
        let lightGreen = UIColor(displayP3Red: 0.0, green: 1.0, blue: 0.0, alpha: 0.4)
        
        if size < 3 {
            return lightRed
        } else if size >= 3 && size <= 4 {
            return lightYellow
        } else {
            return lightGreen
        }
    }
    
    func refreshPage() {
        
        // Refresh Date/Time
        self.dateLabel.text = holdArray[0]
        self.hourLabel.text = holdArray[1]
        
        // Refresh El Porto View
        self.portoSpotLabel.text = holdArray[2]
        self.portoSizeLabel.text = holdArray[4]
        self.portoShapeLabel.text = holdArray[5]
        self.portoConditionsView.backgroundColor = pickColor(size: Int(holdArray[3])!)
        
        if holdArray.count > 6 && holdArray.count <= 12 {
            
            // Refresh PV Cove View
            self.pvCoveSpotLabel.text = holdArray[8]
            self.pvCoveSizeLabel.text = holdArray[10]
            self.pvCoveShapeLabel.text = holdArray[11]
            self.pvCoveConditionsView.backgroundColor = pickColor(size: Int(holdArray[9])!)
            
        } else if holdArray.count > 12 {
            
            // Refresh PV Cove View
            self.pvCoveSpotLabel.text = holdArray[8]
            self.pvCoveSizeLabel.text = holdArray[10]
            self.pvCoveShapeLabel.text = holdArray[11]
            self.pvCoveConditionsView.backgroundColor = pickColor(size: Int(holdArray[9])!)
            
            // Refresh Hermosa Beach View
            self.hermosaSpotLabel.text = holdArray[14] + " Beach"
            self.hermosaSizeLabel.text = holdArray[16]
            self.hermosaShapeLabel.text = holdArray[17]
            self.hermosaConditionsView.backgroundColor = pickColor(size: Int(holdArray[15])!)
        }
        self.view.setNeedsLayout()
    }
    
    func getDate() -> [String] {
        let date = Date()
        let calendar = Calendar.current
        let day = String(calendar.component(.day, from: date))
        let month = date.monthAsString()
        let year = String(calendar.component(.year, from: date))
        let hour = String(calendar.component(.hour, from: date))
        let dateString = "\(month) \(day), \(year)"
        
        var dateArray: [String] = [dateString, hour]
        
        var currentHour = Int(dateArray[1])!
        
        var hourString = ""
        
        if currentHour >= 13 {
            currentHour -= 12
            hourString = String(currentHour)
            hourString += " PM"
        } else if currentHour == 12 {
            hourString = "12 PM"
        } else {
            hourString = String(currentHour)
            hourString += " AM"
        }
        dateArray.append(hourString)
        
        return dateArray
    }
}

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: self)
}
}
