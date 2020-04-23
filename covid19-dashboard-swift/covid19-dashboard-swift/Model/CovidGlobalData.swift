//
//  CovidGlobalData.swift
//  covid19-dashboard-swift
//
//  Created by Sam Bowen-hughes on 23/04/2020.
//  Copyright © 2020 Sam Bowen-hughes. All rights reserved.
//

import Foundation

/**
 Covid global data response ( which is annoyingly slighty different to the country response ) 
 */
struct CovidGlobalData: Codable{
    let count: Int;
    let date: String;
    let result : Result;
}
