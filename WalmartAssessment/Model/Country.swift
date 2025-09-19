//
//  Country.swift
//  WalmartAssessment
//
//  Created by Arpit Mallick on 9/19/25.
//

import Foundation

struct Country: Decodable, Equatable {
    let name: String
    let region: String
    let code: String
    let capital: String
}
