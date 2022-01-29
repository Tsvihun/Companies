//
//  Company.swift
//  CoreDataCourse
//
//  Created by Лилия on 09.12.2021.
//

import Foundation

struct JSONCompany: Decodable {
    let name: String
    var founded: String?
    let photoUrl: String
    var employees: [JSONEmployee]?
}

struct JSONEmployee: Decodable {
    let name: String
    let birthday: String
    let type: String
}
