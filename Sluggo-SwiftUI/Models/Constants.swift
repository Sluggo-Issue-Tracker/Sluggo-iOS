//
//  Constants.swift
//  Sluggo
//
//  Created by Troy Ebert on 4/21/21.
//

import Foundation

// swiftlint:disable identifier_name
struct Constants {

    struct FilePaths {

        static let persistencePath = "/Library/sluggodata.json"

    }

    struct Config {

        static let URL_BASE = "http://127.0.0.1:8000/"
        static let kURL = "url"

    }

    struct Signals {
        static let TEAM_CHANGE_NOTIFICATION = NSNotification.Name(rawValue: "teamChange")
    }
}
