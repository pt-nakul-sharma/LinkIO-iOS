import Foundation
import UIKit

public class LinkIO {
    public static let shared = LinkIO()

    private var config: LinkIOConfig?
    private var pendingDeepLink: DeepLinkData?
    private var deepLinkHandler: ((DeepLinkData) -> Void)?

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    public func configure(config: LinkIOConfig) {
        self.config = config
        if config.autoCheckPendingLinks {
            checkPendingLink()
        }
    }

    public func handleUniversalLink(url: URL) -> Bool {
        guard let config = config else { return false }

        guard url.host == config.domain || url.host == "www.\(config.domain)" else {
            return false
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var params: [String: String] = [:]

        components?.queryItems?.forEach { item in
            params[item.name] = item.value
        }

        let deepLink = DeepLinkData(
            url: url.absoluteString,
            params: params,
            isDeferred: false
        )

        if let handler = deepLinkHandler {
            handler(deepLink)
        } else {
            pendingDeepLink = deepLink
        }

        return true
    }

    public func setDeepLinkHandler(_ handler: @escaping (DeepLinkData) -> Void) {
        self.deepLinkHandler = handler

        if let pending = pendingDeepLink {
            handler(pending)
            pendingDeepLink = nil
        }
    }

    public func checkPendingLink() {
        guard let config = config else { return }

        let deviceId = getDeviceId()
        let urlString = "\(config.backendURL)pending-link/\(deviceId)"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let deepLink = try decoder.decode(DeepLinkData.self, from: data)

                DispatchQueue.main.async {
                    if let handler = self.deepLinkHandler {
                        handler(deepLink)
                    } else {
                        self.pendingDeepLink = deepLink
                    }
                }
            } catch {
                print("LinkIO: Failed to decode pending link - \(error)")
            }
        }.resume()
    }

    public func trackReferral(referralCode: String, userId: String, metadata: [String: Any]? = nil) {
        guard let config = config else { return }

        let urlString = "\(config.backendURL)track-referral"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "referralCode": referralCode,
            "userId": userId
        ]

        if let metadata = metadata {
            body["metadata"] = metadata
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("LinkIO: Failed to track referral - \(error)")
            }
        }.resume()
    }

    private func getDeviceId() -> String {
        let key = "com.linkio.deviceId"

        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }

        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }

    @objc private func applicationDidBecomeActive() {
        if config?.autoCheckPendingLinks == true {
            checkPendingLink()
        }
    }
}
