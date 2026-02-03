import Foundation

public struct DeepLinkData: Codable {
    public let url: String
    public let params: [String: String]
    public let isDeferred: Bool
    
    public init(url: String, params: [String: String], isDeferred: Bool) {
        self.url = url
        self.params = params
        self.isDeferred = isDeferred
    }
}
