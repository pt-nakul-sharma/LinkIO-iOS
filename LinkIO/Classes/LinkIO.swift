import Foundation
import UIKit

@MainActor
public final class LinkIO {
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

    /// Handle Universal Links (https://domain.com/...) and custom URL schemes (appscheme://...)
    public func handleUniversalLink(url: URL) -> Bool {
        guard let config = config else { return false }

        // Check if it's a domain URL (Universal Link)
        let isDomainURL = url.host == config.domain || url.host == "www.\(config.domain)"

        // Check if it's an app scheme URL
        let isAppSchemeURL = config.appScheme != nil && url.scheme == config.appScheme

        guard isDomainURL || isAppSchemeURL else {
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

        deliver(deepLink)

        return true
    }

    /// Convenience method for handling app scheme URLs in AppDelegate
    public func handleAppSchemeURL(url: URL) -> Bool {
        return handleUniversalLink(url: url)
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

        // Use fingerprint-based endpoint (IP matching) for deferred deep linking
        // This works even when User-Agent differs between browser and app
        let urlString = "\(config.backendURL)pending-link"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                // Fallback to deviceId-based endpoint
                Task { @MainActor in self?.checkPendingLinkByDeviceId() }
                return
            }

            // An empty / url-less 200 (e.g. `{}`) means "no pending link" — not an error.
            // Try the deviceId-based endpoint instead of logging a decode failure.
            if Self.isEmptyPendingLink(data) {
                Task { @MainActor in self?.checkPendingLinkByDeviceId() }
                return
            }

            do {
                let decoder = JSONDecoder()
                let deepLink = try decoder.decode(DeepLinkData.self, from: data)
                Task { @MainActor in self?.deliver(deepLink) }
            } catch {
                print("LinkIO: Failed to decode pending link - \(error)")
                // Fallback to deviceId-based endpoint
                Task { @MainActor in self?.checkPendingLinkByDeviceId() }
            }
        }.resume()
    }

    /// True when the pending-link response carries no deep link (empty object or missing
    /// `url`), which the backend returns as HTTP 200 `{}` when nothing is waiting.
    nonisolated private static func isEmptyPendingLink(_ data: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        return object["url"] == nil
    }

    /// Deliver a decoded deep link to the registered handler, or hold it as pending.
    private func deliver(_ deepLink: DeepLinkData) {
        if let handler = deepLinkHandler {
            handler(deepLink)
        } else {
            pendingDeepLink = deepLink
        }
    }

    private func checkPendingLinkByDeviceId() {
        guard let config = config else { return }

        let deviceId = getDeviceId()
        let urlString = "\(config.backendURL)pending-link/\(deviceId)"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return
            }

            // Empty / url-less 200 means there is genuinely no pending link — stop silently.
            if Self.isEmptyPendingLink(data) { return }

            do {
                let decoder = JSONDecoder()
                let deepLink = try decoder.decode(DeepLinkData.self, from: data)
                Task { @MainActor in self?.deliver(deepLink) }
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
