//
//  PaymentType.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import Foundation

class PaymentType: Codable{
    
    var createDate: String?
    var id: Int
    var typeName: String
    
    init(createDate: String? = nil, id: Int, typeName: String) {
        self.createDate = createDate
        self.id = id
        self.typeName = typeName
    }
    
}

