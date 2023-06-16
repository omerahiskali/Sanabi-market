//
//  AddressData.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import Foundation

class AddressData: Codable{
    var data:Address?
    var errors:String?
    
    init(data: Address? = nil, errors: String? = nil) {
        self.data = data
        self.errors = errors
    }

}
