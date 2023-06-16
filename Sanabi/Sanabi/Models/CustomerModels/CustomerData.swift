//
//  CustomerData.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 1.06.2023.
//

import Foundation

class CustomerData: Codable{
    var data: Customer?
    var errors: String?
    
    init(data: Customer? = nil, errors: String? = nil) {
        self.data = data
        self.errors = errors
    }
}
