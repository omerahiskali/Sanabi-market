//
//  AddressList.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 31.05.2023.
//

import Foundation

class AddressList: Codable{
    var data:[Address]?
    var errors:String?
    
    init(data: [Address], errors: String? = nil) {
        self.data = data
        self.errors = errors
    }

}

