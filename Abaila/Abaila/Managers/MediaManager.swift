//
//  MediaManager.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 8/13/25.
//

import Foundation
import UIKit

enum MediaError: Error {
    case failedToAccessPresignedURL
    case invalidResponse
    case networkError(Error)
}

class MediaManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    
    func uploadMedia(_ mediaItems: [MediaItem]) async throws -> [String] {
        var uploadedURLs: [String] = []
        
        for mediaItem in mediaItems {
            let uploadURL = try await uploadMediaItem(mediaItem)
            uploadedURLs.append(uploadURL)
        }
        return uploadedURLs
    }
    
    private func uploadMediaItem(_ mediaItem: MediaItem) async throws -> String {
        // Get media data
        let mediaData = try await getMediaData(from: mediaItem)
        let contentType = mediaItem.isVideo ? "video/mp4" : "image/jpeg"
//        print(mediaData)
        // Request presigned URL from backend
        let presignedResponse = try await putPresignedUrl()
//        print("Presigned URL", presignedResponse)
        // Upload to S3 using presigned URL
        try await uploadToS3(data: mediaData, presignedURL: presignedResponse.uploadURL, contentType: contentType)
        return presignedResponse.key
    }
    
    private func getMediaData(from mediaItem: MediaItem) async throws -> Data {
        let originalItem = mediaItem.originalItem
        
        if mediaItem.isVideo {
            // Load raw video data
            guard let data = try await originalItem.loadTransferable(type: Data.self) else {
                throw MediaError.invalidResponse
            }
            return data
        } else {
            // Load image as Data, then optionally recompress to JPEG
            guard let data = try await originalItem.loadTransferable(type: Data.self) else {
                throw MediaError.invalidResponse
            }
            if let image = UIImage(data: data),
               let jpegData = image.jpegData(compressionQuality: 0.8) {
                return jpegData
            }
            // Fallback: return original data
            return data
        }
    }
    
    func putPresignedUrl() async throws -> PresignedURL {
        guard let url = URL(string: "http://localhost:3000/media/presigned-url") else {
            throw MediaError.invalidResponse
        }
        
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
        
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MediaError.invalidResponse
            }
            if httpResponse.statusCode == 200 {
                await MainActor.run {
                    isLoading = false
                }
                
                let decoder = JSONDecoder()
                do {
                    let presigned = try decoder.decode(PresignedURL.self, from: data)
                    return presigned
                } catch {
                    print("Error decoding presigned URL: \(error)")
                    throw MediaError.invalidResponse
                }
            } else if httpResponse.statusCode == 403 {
                try await authViewModel.authenticationStatus()
                return try await putPresignedUrl()
            } else {
                throw MediaError.failedToAccessPresignedURL
            }
        } catch {
            throw MediaError.networkError(error)
        }
    }
    
    private func uploadToS3(data: Data, presignedURL: String, contentType: String) async throws {
        guard let url = URL(string: presignedURL) else { throw MediaError.invalidResponse}
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MediaError.failedToAccessPresignedURL
        }
    }
    
    func getSignedURLs(keys: [String]) async throws -> [String] {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/media/getSignedUrl"
        components.queryItems = keys.map { URLQueryItem(name: "key", value: $0) }
        print("keys:", keys)
        guard let url = components.url else {
            throw MediaError.invalidResponse
        }
        
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw MediaError.invalidResponse }
            
            switch http.statusCode {
            case 200:
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(Array<String>.self, from: data)
                return decodedData
            case 403:
                try await authViewModel.authenticationStatus()
                return try await getSignedURLs(keys: keys)
            default:
                throw MediaError.failedToAccessPresignedURL
            }
        } catch {
            throw MediaError.networkError(error)
        }
    }
}
