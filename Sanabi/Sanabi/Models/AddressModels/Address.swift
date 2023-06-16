//
//  Address.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 31.05.2023.
//

import Foundation

class Address: Codable, Equatable{
    var apartmentNumber:Int
    var buildingNo:Int
    var createDate:String?
    var customerId:Int
    var districte:String
    var id:Int
    var name:String
    var neighbourhood:String
    var postCode:Int
    var province:String
    var street:String
    var adressDetails:String
    var numberPhone:String
    
    init(apartmentNumber: Int, buildingNo: Int, createDate: String? = nil, customerId: Int, districte: String, id: Int, name: String, neighbourhood: String, postCode: Int, province: String, street: String, adressDetails: String, numberPhone: String) {
        self.apartmentNumber = apartmentNumber
        self.buildingNo = buildingNo
        self.createDate = createDate
        self.customerId = customerId
        self.districte = districte
        self.id = id
        self.name = name
        self.neighbourhood = neighbourhood
        self.postCode = postCode
        self.province = province
        self.street = street
        self.adressDetails = adressDetails
        self.numberPhone = numberPhone
    }
    
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.id == rhs.id
    }
}


