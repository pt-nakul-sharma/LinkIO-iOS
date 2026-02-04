import Foundation

public struct LinkIOConfig {
    public let domain: String
    public let backendURL: String
    public let appScheme: String? // Custom URL scheme (e.g., "rokart" for rokart://)
    public let autoCheckPendingLinks: Bool

    public init(
        domain: String,
        backendURL: String,
        appScheme: String? = nil,
        autoCheckPendingLinks: Bool = true
    ) {
        self.domain = domain
        self.backendURL = backendURL
        self.appScheme = appScheme
        self.autoCheckPendingLinks = autoCheckPendingLinks
    }
}
