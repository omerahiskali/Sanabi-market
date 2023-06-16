//
//  ProductList.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 2.06.2023.
//

import Foundation

class ProductList:Codable{
    var data:[Products]?
    var errors:String?
    
    init(data: [Products]? = nil, errors: String? = nil) {
        self.data = data
        self.errors = errors
    }
    
}

