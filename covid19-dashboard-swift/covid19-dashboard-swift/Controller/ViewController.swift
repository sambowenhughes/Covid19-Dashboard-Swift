//
//  ViewController.swift
//  covid19-dashboard-swift
//
//  Created by Sam Bowen-hughes on 21/04/2020.
//  Copyright © 2020 Sam Bowen-hughes. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CovidServiceDelegate  {    
    
    @IBOutlet weak var deathTollLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var recoverRateLabel: UILabel!
    @IBOutlet weak var numberOfCasesLabel: UILabel!
    
    @IBOutlet weak var totalInfectedCount: UILabel!
    @IBOutlet weak var totalRecoveredCount: UILabel!
    @IBOutlet weak var totalDeathsCount: UILabel!
    var covidService = CovidService();
    var countryService = CountryService();
    var selectedCountryData =  CountryData().countries;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.covidService.delegate = self;
        self.countryPicker.delegate = self;
        self.countryPicker.dataSource = self;
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectedCountryData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let countryName = Array(selectedCountryData)[row].values;
        return countryName.first!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let countryKey = Array(selectedCountryData)[row].keys;
        let countryName = Array(selectedCountryData)[row].values;
        self.countryLabel.text = countryName.first!;
        
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        let currentDate = formatter.string(from: date);
        
        self.covidService.fetchData(countryCode: countryKey.first!, date: currentDate);
    }
    
    func didUpdateCovidData(_ covidService: CovidService, covidData: CovidData){
        let confirmed = covidData.result.last?.confirmed;
        let recovered = covidData.result.last?.recovered;
        let deaths = covidData.result.last?.deaths;
        
        
        if let deaths = deaths {
            let result = String(deaths)
            DispatchQueue.main.async {
                self.totalDeathsCount.text = result;
            }
        }
        
        if let recovered = recovered {
            let result = String(recovered)
            DispatchQueue.main.async {
                self.totalRecoveredCount.text = result;
            }
        }
        
        if let confirmed = confirmed {
            let result = String(confirmed)
            DispatchQueue.main.async {
                self.totalInfectedCount.text = result;
            }
        }
        
        
        //        self.totalDeathsCount.text = String (deaths);
        //        self.totalInfectedCount.text = (covidData.result.last?.confirmed!);
        //        self.totalRecoveredCount.text = covidData.result.last.recovered;
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

