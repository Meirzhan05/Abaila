//
//  PushNotificationManager.swift
//  Abaila
//

import Foundation
import UIKit
import UserNotifications

final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()

    private let tokenKey = "apnsDeviceToken"
    private override init() {}

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
                return
            }
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func handleDidRegister(deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: tokenKey)
        syncTokenIfPossible()
    }

    func syncTokenIfPossible() {
        guard let token = UserDefaults.standard.string(forKey: tokenKey),
              let accessToken = UserDefaults.standard.string(forKey: "accessToken") else { return }

        guard let url = URL(string: "http://localhost:3000/devices/apns/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let body = ["deviceToken": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("APNs token sync error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse {
                print("APNs token sync status: \(http.statusCode)")
            }
        }.resume()
    }
}


