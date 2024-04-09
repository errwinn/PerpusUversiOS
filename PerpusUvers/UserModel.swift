//
//  UserModel.swift
//  PerpusUvers
//
//  Created by Erwin on 04/04/24.
//

import Foundation

struct UserModel: Codable {
    let data: UserData
}

struct UserData: Codable {
    let name: String
    let access_token: String
    let refresh_token: String
}
