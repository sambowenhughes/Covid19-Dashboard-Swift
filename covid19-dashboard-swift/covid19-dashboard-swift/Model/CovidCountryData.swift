//
//  CovidData.swift
//  covid19-dashboard-swift
//
//  Created by Sam Bowen-hughes on 21/04/2020.
//  Copyright © 2020 Sam Bowen-hughes. All rights reserved.
//

import Foundation

/**
 Covid country date response
 */
struct CovidCountryData: Codable {
    let count : Int;
    let result : [Result];
}

struct Result: Codable{
    let confirmed : Int;
    let date : String?;
    let deaths : Int;
    let recovered : Int;
}
