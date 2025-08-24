// Swift
import Foundation
import SwiftUI

struct AlertResponse: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let media: [String]
    let mediaType: String?
    let likes: Int
    let comments: Int
    let views: Int
    let alertType: AlertType
    let location: GeoJSONPoint?  // Changed from String? to GeoJSONPoint?
    let createdAt: Date
    let createdBy: String
    var signedMedia: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, media, mediaType, likes, comments, views, location
        case alertType = "type"
        case createdAt, createdBy
    }

    static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { dec in
            let c = try dec.singleValueContainer()
            let s = try c.decode(String.self)

            if let date = {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return f.date(from: s)
            }() { return date }

            if let date = ISO8601DateFormatter().date(from: s) { return date }

            if let date = {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                return f.date(from: s)
            }() { return date }

            if let date = {
                let f = DateFormatter()
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                return f.date(from: s)
            }() { return date }

            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unrecognized date: \(s)")
        }
        return d
    }
}

struct AlertCreateRequest: Codable {
    let title: String
    let description: String
    let type: AlertType
    let location: GeoJSONPoint
    let media: [String]?
}

struct GeoJSONPoint: Codable {
    let type: String
    let coordinates: [Double]
    
    init(longitude: Double, latitude: Double) {
        self.type = "Point"
        self.coordinates = [longitude, latitude]
    }
}
enum AlertManagerError: Error {
    case notAuthenticated
    case badURL
    case invalidResponse
    case serverStatus(Int)
    case decoding
}
