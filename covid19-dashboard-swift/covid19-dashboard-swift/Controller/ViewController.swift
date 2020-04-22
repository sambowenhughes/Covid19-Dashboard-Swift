//
//  ViewController.swift
//  covid19-dashboard-swift
//
//  Created by Sam Bowen-hughes on 21/04/2020.
//  Copyright © 2020 Sam Bowen-hughes. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController  {
    // Country Picker
    @IBOutlet weak var countryPicker: UIPickerView!
    
    // Pie Chart Properties
    @IBOutlet weak var pieChartView: PieChartView!
    var totalDeaths = PieChartDataEntry(value:0)
    var totalRecovered = PieChartDataEntry(value:0)
    var totalInfected = PieChartDataEntry(value:0)
    var numberOfDataEntries = [PieChartDataEntry]()
    
    // Data Services
    var covidService = CovidService();
    var countryService = CountryService();
    var selectedCountryData =  CountryData().countries;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChart();
        updateChartData();
        
        self.covidService.delegate = self;
        self.countryPicker.delegate = self;
        self.countryPicker.dataSource = self;
    }
    
    func setupChart(){
        pieChartView.chartDescription?.text = ""
        pieChartView.legend.enabled = false;
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInBack)
        numberOfDataEntries = [totalDeaths, totalInfected, totalRecovered];
    }
    
    func updateChartData(){
        let chartDataSet = PieChartDataSet(entries: numberOfDataEntries, label: nil);
        let chartData = PieChartData(dataSet: chartDataSet);
        
        let colors = [UIColor.init(named: "deathCountColor"),UIColor.init(named: "recoveredCountColor"),UIColor.init(named: "infectedCountColor")];
        
        chartDataSet.colors = colors as! [NSUIColor];
        pieChartView.data = chartData;
    }
}

// MARK : CovidServiceDelegate

extension ViewController: CovidServiceDelegate{
    
    func didUpdateCovidData(_ covidService: CovidService, covidData: CovidData){
        let confirmed = covidData.result.last?.confirmed;
        let recovered = covidData.result.last?.recovered;
        let deaths = covidData.result.last?.deaths;
        
        self.totalInfected.value = Double(confirmed!);
        self.totalRecovered.value = Double(recovered!);
        self.totalDeaths.value = Double(deaths!);
        
        DispatchQueue.main.async {
            self.updateChartData();
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

// MARK - UIPickerDelegate

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 20.0)! ]
        let myAttrString = NSAttributedString(string: countryName.first!, attributes: myAttribute)
        
        self.pieChartView.centerAttributedText = myAttrString;
        
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        let currentDate = formatter.string(from: date);
        
        self.covidService.fetchData(countryCode: countryKey.first!, date: currentDate);
    }
}


