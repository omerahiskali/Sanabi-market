//
//  Category.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 1.06.2023.
//

import Foundation

class Categorys: Codable{
    var createDate: String
    var id: Int
    var image: String
    var name: String
    
    init(createDate: String, id: Int, image: String, name: String) {
        self.createDate = createDate
        self.id = id
        self.image = image
        self.name = name
    }
}

