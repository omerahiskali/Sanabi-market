//
//  ProductData.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import Foundation

class ProductData: Codable{
    
    var categoryId: Int
    var createdDate: String?
    var description: String
    var id: Int
    var image: String
    var name: String
    var price: Double
    var stock: Int
    
    init(categoryId: Int, createdDate: String? = nil, description: String, id: Int, image: String, name: String, price: Double, stock: Int) {
        self.categoryId = categoryId
        self.createdDate = createdDate
        self.description = description
        self.id = id
        self.image = image
        self.name = name
        self.price = price
        self.stock = stock
    }
    
}


