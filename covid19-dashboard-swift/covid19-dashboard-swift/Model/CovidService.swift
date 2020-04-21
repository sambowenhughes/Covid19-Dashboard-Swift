//
//  CovidService.swift
//  covid19-dashboard-swift
//
//  Created by Sam Bowen-hughes on 21/04/2020.
//  Copyright © 2020 Sam Bowen-hughes. All rights reserved.
//

import Foundation

protocol CovidServiceDelegate {
    func didUpdateCovidData(_ covidService: CovidService, covidData: CovidData);
    func didFailWithError(error: Error)
}

struct CovidService {
    let dataUrl = "https://covidapi.info/api/v1/country";

    var delegate: CovidServiceDelegate?;
    
    func fetchData(countryCode: String, date: String){
        let urlString = "\(dataUrl)/\(countryCode)/timeseries/2019-01-01/\(date)";
        self.performRequest(with : urlString);
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default);
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return;
                }
                if let safeData = data {
                    if let covidData = self.parseJSON(safeData){
                        self.delegate?.didUpdateCovidData(self, covidData: covidData)
                    }
                }
            }
            
            task.resume();
        }
    }
    
    func parseJSON(_ data: Data) -> CovidData? {
        let decoder = JSONDecoder();
        do {
            let decodedData = try decoder.decode(CovidData.self, from: data)
//            print(decodedData);
//            print(decodedData.result.last!.confirmed)
//            print(decodedData.result.last!.recovered)
//            print(decodedData.result.last!.deaths)
            return decodedData;
        }
        catch {
            self.delegate?.didFailWithError(error: error)
            return nil;
        }
            
    }
}
