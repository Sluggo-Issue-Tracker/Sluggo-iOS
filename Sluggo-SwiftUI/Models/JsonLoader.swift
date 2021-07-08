//
//  JsonLoader.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/19/21.
//

import Foundation

class JsonLoader {
    static func decode<T: Codable>(data: Data) -> T? {
        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        var decodedValue: T?
        do {
            decodedValue = try decoder.decode(T.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            print("\(context.codingPath) . \(context.debugDescription)")
        } catch let context {
            switch context {
            case DecodingError.dataCorrupted(let value):
                print(value.debugDescription)
            default:
                print(context.localizedDescription)

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
            print("Failed to encode object into JSON data.")
            return nil

        }

        // Attempt stringifying the data, this is failable, which is fine since property is optional.
        return jsonData
    }
    
    static func executeCodableRequest<T: Codable>(request: URLRequest) async -> Result<T, Error> {

        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: request)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                guard let record: T = JsonLoader.decode(data: data) else {
                    print(String(data: data, encoding: .utf8) ?? "Failed to print returned values")
                    let errorMessage = "Failure to decode retrieved model in JsonLoader Codable Request"
                    return .failure(RESTException.failedRequest(message: errorMessage))
                }
                return .success(record)
            } else {
                let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
                let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                return .failure(RESTException.failedRequest(message: errorMessage))
            }
        }
        catch {
            return .failure(Exception.runtimeError(message: "Server Error!"))
        }
    }

    static func executeEmptyRequest(request: URLRequest) async -> Result<Void, Error> {
        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: request)
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                return .success(())
            } else {
                let fetchedString = String(data: data, encoding: .utf8) ?? "A parsing error occurred"
                let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                return .failure(RESTException.failedRequest(message: errorMessage))
            }
        }
        catch {
           return .failure(Exception.runtimeError(message: "Server Error!"))
        }
    }
}
