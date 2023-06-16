//
//  Customers.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 24.05.2023.
//

import Foundation

class Customer: Codable {
    var name: String
    var surname: String
    var mail: String?
    var numberPhone: String
    var birtDate: String?
    var id: Int
    var createDate: String?

    init(name: String, surname: String, mail: String? = nil, numberPhone: String, birtDate: String? = nil, id: Int, createDate: String? = nil) {
        self.name = name
        self.surname = surname
        self.mail = mail
        self.numberPhone = numberPhone
        self.birtDate = birtDate
        self.id = id
        self.createDate = createDate
    }
    
}
