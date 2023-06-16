//
//  OrderStatus.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import Foundation

class OrderStatus: Codable{
    
    var createDate: String?
    var id: Int
    var statusType: String
    
    init(createDate: String? = nil, id: Int, statusType: String) {
        self.createDate = createDate
        self.id = id
        self.statusType = statusType
    }
    
}


