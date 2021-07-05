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

    static func executeCodableRequest<T: Codable>(request: URLRequest,
                                                  completionHandler: @escaping (Result<T, Error>) -> Void) {

        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if error != nil {
                completionHandler(.failure(Exception.runtimeError(message: "Server Error!")))
                return
            }
            // swiftlint:disable:next force_cast
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                if let fetchedData = data {
                    guard let record: T = JsonLoader.decode(data: fetchedData) else {
                        print(String(data: fetchedData, encoding: .utf8) ?? "Failed to print returned values")
                        let errorMessage = "Failure to decode retrieved model in JsonLoader Codable Request"
                        completionHandler(.failure(RESTException.failedRequest(message: errorMessage)))
                        return
                    }
                    completionHandler(.success(record))
                    return
                } else {
                    let errorMessage = "Failure to decode retrieved data in JsonLoader Codable request"
                    completionHandler(.failure(RESTException.failedRequest(message: errorMessage)))
                    return
                }
            } else {
                if let fetchedData = data {
                    let fetchedString = String(data: fetchedData, encoding: .utf8) ?? "A parsing error occurred"
                    let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                    completionHandler(.failure(RESTException.failedRequest(message: errorMessage)))
                    return
                }
                let errorMessage = "HTTP Error \(resp.statusCode): An unknown error occured."
                completionHandler(.failure(RESTException.failedRequest(message: errorMessage)))
                return
            }
        }).resume()
    }

    static func executeEmptyRequest(request: URLRequest,
                                    completionHandler: @escaping (Result<Void, Error>) -> Void) {

        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if error != nil {
                completionHandler(.failure(Exception.runtimeError(message: "Server Error!")))
                return
            }
            // swiftlint:disable:next force_cast
            let resp = response as! HTTPURLResponse
            if resp.statusCode <= 299 && resp.statusCode >= 200 {
                completionHandler(.success(()))
                return
            } else {
                if let fetchedData = data {
                    let fetchedString = String(data: fetchedData, encoding: .utf8) ?? "A parsing error occurred"
                    let errorMessage = "HTTP Error \(resp.statusCode): \(fetchedString)"
                    completionHandler(.failure(RESTException.failedRequest(message: errorMessage)))
                    return
                }
                let errorMessage = "HTTP Error \(resp.statusCode): An unknown error occured."
                completionHandler(.failure(RESTException.failedRequest(message: errorMessage)))
                return
            }
        }).resume()
    }
}
