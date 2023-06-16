//
//  Products.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 2.06.2023.
//

import Foundation

class Products: Codable{
    var categoryId:Int
    var createDate:String?
    var description:String
    var id:Int
    var image:String
    var name:String
    var price:Double
    var stock:Int
    
    init(categoryId: Int, createDate: String? = nil, description: String, id: Int, image: String, name: String, price: Double, stock: Int) {
        self.categoryId = categoryId
        self.createDate = createDate
        self.description = description
        self.id = id
        self.image = image
        self.name = name
        self.price = price
        self.stock = stock
    }
    
}

