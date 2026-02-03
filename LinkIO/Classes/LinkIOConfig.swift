import Foundation

public struct LinkIOConfig {
    public let domain: String
    public let backendURL: String
    public let autoCheckPendingLinks: Bool
    
    public init(
        domain: String,
        backendURL: String,
        autoCheckPendingLinks: Bool = true
    ) {
        self.domain = domain
        self.backendURL = backendURL
        self.autoCheckPendingLinks = autoCheckPendingLinks
    }
}
