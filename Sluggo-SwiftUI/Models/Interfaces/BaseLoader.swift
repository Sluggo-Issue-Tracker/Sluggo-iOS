//
//  BaseLoader.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 7/13/21.
//

import Foundation

class BaseLoader {

    static func decode<T: Codable>(data: Data) -> T? {
        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var decodedValue: T?
        do {
            decodedValue = try decoder.decode(T.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            track("\(context.codingPath) . \(context.debugDescription)")
        } catch let context {
            switch context {
            case DecodingError.dataCorrupted(let value):
                track(value.debugDescription)
            default:
                track(context.localizedDescription)
                track(context)

            }
        }

        return decodedValue
    }

    static func encode<T: Codable>(object data: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        encoder.keyEncodingStrategy = .convertToSnakeCase

        // Attempt encoding
        guard let jsonData = try? encoder.encode(data) else {
            track("Failed to encode object into JSON data.")
            return nil

        }

        // Attempt stringifying the data, this is failable, which is fine since property is optional.
        return jsonData
    }

}
