//
//  User.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct UserRecord: Codable {
    var id: Int
    var email: String
    @NullCodable var firstName: String?
    @NullCodable var lastName: String?
    var username: String
}

struct AuthRecord: Codable {
    var pk: Int
    var email: String
    @NullCodable var firstName: String?
    @NullCodable var lastName: String?
    var username: String
}

struct LoginRecord: Codable {
    var accessToken: String?
    var refreshToken: String?
    var user: AuthRecord?
}

struct RefreshRecord: Codable {
    var refresh: String
}
