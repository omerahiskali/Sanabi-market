//
//  CategoryList.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 1.06.2023.
//

import Foundation

class CategoryList: Codable{
    var data:[Categorys]?
    var errors:String?
    
    init(data: [Categorys], errors: String? = nil) {
        self.data = data
        self.errors = errors
    }
}

