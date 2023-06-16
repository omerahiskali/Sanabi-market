//
//  Product.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import Foundation

class Product: Codable{
    
    var orderId: Int
    var product: ProductData
    var productId: Int
    var productQuantity: Int
    
    init(orderId: Int, product: ProductData, productId: Int, productQuantity: Int) {
        self.orderId = orderId
        self.product = product
        self.productId = productId
        self.productQuantity = productQuantity
    }
    
}


