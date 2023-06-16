//
//  OrderProductModelItem.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import Foundation

class OrderProductModelItem: Codable{
    
    var _Products: [Product]
    var adressId: Int
    var amount: Double
    var createDate: String
    var customer: Customer
    var customerId: Int
    var id: Int
    var orderStatus: OrderStatus
    var orderStatusId: Int
    var paymentType: PaymentType
    var paymentTypeId: Int
    
    init(_Products: [Product], adressId: Int, amount: Double, createDate: String, customer: Customer, customerId: Int, id: Int, orderStatus: OrderStatus, orderStatusId: Int, paymentType: PaymentType, paymentTypeId: Int) {
        self._Products = _Products
        self.adressId = adressId
        self.amount = amount
        self.createDate = createDate
        self.customer = customer
        self.customerId = customerId
        self.id = id
        self.orderStatus = orderStatus
        self.orderStatusId = orderStatusId
        self.paymentType = paymentType
        self.paymentTypeId = paymentTypeId
    }
    
}
