//
//  CovidService.swift
//  covid19-dashboard-swift
//
//  Created by Sam Bowen-hughes on 21/04/2020.
//  Copyright © 2020 Sam Bowen-hughes. All rights reserved.
//

import Foundation

/**
 Covid Service delegate to notify the controller to do a ting
 */
protocol CovidServiceDelegate {
    func didUpdateCountryData(_ covidService: CovidService, covidData: CovidCountryData);
    func didUpdateGlobalData(_ covidService: CovidService, covidGlobalData: CovidGlobalData);
    func didFailWithError(error: Error)
}

struct CovidService {
    /**
     Base URL for all covid related data
     */
    let baseUrl = "https://covidapi.info/api/v1";
    
    /**
     Covid Service Delegate
     */
    var delegate: CovidServiceDelegate?;
    
    /**
     Function used to fetch global data (Possible duplicate - probs only need fetchData with some fancy params)
     */
    func fetchGlobalCount(){
        let urlString = "\(baseUrl)/global";
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default);
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return;
                }
                if let safeData = data {
                    if let data = self.parseCovidGlobalJSON(safeData){
                        self.delegate?.didUpdateGlobalData(self, covidGlobalData: data)
                    }
                }
            }
            task.resume();
        }
        
    }
    
    /**
        Function used to fetch country data (Possible duplicate - probs only need fetchData with some fancy params)
    */
    func fetchCountryData(countryCode: String, date: String){
        let urlString = "\(baseUrl)/country/\(countryCode)/timeseries/2019-01-01/\(date)";
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default);
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return;
                }
                if let safeData = data {
                    if let data = self.parseCovidCountryJSON(safeData){
                        self.delegate?.didUpdateCountryData(self, covidData: data)
                    }
                }
            }
            task.resume();
        }
    }
    
    /**
     Parse covid country data (Possible duplicate)
     */
    func parseCovidCountryJSON(_ data: Data) -> CovidCountryData? {
        let decoder = JSONDecoder();
        do {
            let decodedData = try decoder.decode(CovidCountryData.self, from: data)
            return decodedData;
        }
        catch {
            self.delegate?.didFailWithError(error: error)
            return nil;
        }
        
    }
    
    /**
     Parse covid country data (Possible duplicate)
     */
    func parseCovidGlobalJSON(_ data: Data) -> CovidGlobalData? {
        let decoder = JSONDecoder();
        do {
            let decodedData = try decoder.decode(CovidGlobalData.self, from: data)
            return decodedData;
        }
        catch {
            self.delegate?.didFailWithError(error: error)
            return nil;
        }
        
    }
}
