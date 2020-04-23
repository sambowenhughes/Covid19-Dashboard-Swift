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
    
    /**
     Country Picker
     */
    @IBOutlet weak var countryPicker: UIPickerView!
    
    /**
     Date Updated Label
     */
    @IBOutlet weak var dateUpdatedLabel: UILabel!
    
    /**
     Pie Chart Properties
     */
    @IBOutlet weak var pieChartView: PieChartView!
    var totalDeaths = PieChartDataEntry(value:0, label:"Deaths")
    var totalRecovered = PieChartDataEntry(value:0, label:"Recovered")
    var totalInfected = PieChartDataEntry(value:0, label:"Confirmed")
    var numberOfDataEntries = [PieChartDataEntry]()
    
    /**
     Data Services
     */
    var covidService = CovidService();
    var selectedCountryData =  CountryData().countries;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupChart();
        
        self.covidService.delegate = self;
        self.countryPicker.delegate = self;
        self.countryPicker.dataSource = self;
        
        self.covidService.fetchGlobalCount();
    }
    
    /**
     Setup Pie Chart
     */
    func setupChart(){
        pieChartView.entryLabelColor = UIColor.white;
        pieChartView.chartDescription?.text = ""
        pieChartView.legend.enabled = false;
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInBack)
        numberOfDataEntries = [totalDeaths, totalInfected, totalRecovered];
    }
    
    /**
     Update Pie Chart Data
     */
    func updateChartData(){
        let chartDataSet = PieChartDataSet(entries: numberOfDataEntries, label: nil);
        let chartData = PieChartData(dataSet: chartDataSet);
        chartData.setValueFont( UIFont(name: "Helvetica-Bold", size: 15.0 )!)
        let colors = [UIColor.init(named: "deathCountColor"),UIColor.init(named: "recoveredCountColor"),UIColor.init(named: "infectedCountColor")];
        chartDataSet.colors = colors as! [NSUIColor];
        pieChartView.data = chartData;
    }
    
    /**
     Helper function to update Pie Chart centered text
     */
    func updateChartCenterText(_ name : String){
        let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 15.0 )!,  NSAttributedString.Key.foregroundColor: UIColor(named:"recoveredCountColor") ]
        let myAttrString = NSAttributedString(string: name, attributes: myAttribute as [NSAttributedString.Key : Any])
        
        self.pieChartView.centerAttributedText = myAttrString;
    }
    
    /**
     Helper function to format date (Should probably be done service leve - oops)
     */
    func formatDate(_ date : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return  dateFormatter.string(from: date!)
    }
}

// MARK : CovidServiceDelegate

extension ViewController: CovidServiceDelegate{
    
    /**
     Function called once global data has been retrieved (possible duplicate)
     */
    func didUpdateGlobalData(_ covidService: CovidService, covidGlobalData: CovidGlobalData) {
        let confirmed = covidGlobalData.result.confirmed;
        let recovered = covidGlobalData.result.recovered;
        let deaths = covidGlobalData.result.deaths;
        
        self.totalInfected.value = Double(confirmed);
        self.totalRecovered.value = Double(recovered);
        self.totalDeaths.value = Double(deaths);
        
        let formattedDate = formatDate(covidGlobalData.date)
        
        DispatchQueue.main.async {
            self.updateChartCenterText("Global Stats")
            self.dateUpdatedLabel.text = "DATA LAST UPDATED: \(formattedDate)";
            self.updateChartData();
        }
    }
    
    /**
     Function called once country data has been retrieved (possible duplicate)
     */
    func didUpdateCountryData(_ covidService: CovidService, covidData: CovidCountryData){
        let confirmed = covidData.result.last?.confirmed;
        let recovered = covidData.result.last?.recovered;
        let deaths = covidData.result.last?.deaths;
        
        self.totalInfected.value = Double(confirmed!);
        self.totalRecovered.value = Double(recovered!);
        self.totalDeaths.value = Double(deaths!);
        
        let date =  covidData.result.last?.date;
        let formattedDate = formatDate(date!)
        
        DispatchQueue.main.async {
            self.dateUpdatedLabel.text = "DATA LAST UPDATED: \(formattedDate)";
            self.updateChartData();
        }
    }
    
    
    /**
     Delegate function to catch any errors
     */
    func didFailWithError(error: Error) {
        print(error)
    }
}

// MARK - UIPickerDelegate

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    /**
     Number of components in thepicker view (i.e. 1 = Countries)
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     Number of rows in the picker view - Number of countries coming from country data
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectedCountryData.count
    }
    
    /**
     Title for each row from the picker - value of the country data array (also used for styling the picker view)
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)
            pickerLabel?.textAlignment = .center
        }
    
        pickerLabel?.text =  Array(selectedCountryData)[row].values.first!
        pickerLabel?.textColor = UIColor(named:"recoveredCountColor")
        
        return pickerLabel!
    }
    
    /**
     Function called once a country has been selected from the picker view
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let countryKey = Array(selectedCountryData)[row].keys;
        let countryName = Array(selectedCountryData)[row].values;
        
        self.updateChartCenterText( countryName.first!)
        self.covidService.fetchCountryData(countryCode: countryKey.first!, date: getCurrentDate());
    }
    
    /**
     Helper function to return the current date
     */
    func getCurrentDate() -> String{
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        let currentDate = formatter.string(from: date);
        return currentDate;
    }
}


