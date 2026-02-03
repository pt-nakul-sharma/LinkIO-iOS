# LinkIO iOS

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0+-blue.svg)](https://developer.apple.com/ios/)

Self-hosted deep linking SDK for iOS. Open-source alternative to Branch.io.

## 🚀 Installation

### Swift Package Manager (Recommended)

**In Xcode:**

1. File → Add Packages...
2. Enter: `https://github.com/pt-nakul-sharma/LinkIO-iOS.git`
3. Select version rule: "Up to Next Major" starting from 1.0.0
4. Click "Add Package"

**In Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/pt-nakul-sharma/LinkIO-iOS.git", from: "1.0.0")
]
```

## 📱 Quick Start

### 1. Configure in AppDelegate

```swift
import UIKit
import LinkIO

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let config = LinkIOConfig(
            domain: "yourdomain.com",
            backendURL: "https://yourdomain.com"
        )
        LinkIO.shared.configure(config: config)

        LinkIO.shared.setDeepLinkHandler { deepLink in
            print("Received: \(deepLink.params)")

            if let referralCode = deepLink.params["referralCode"] {
                // Auto-fill referral code in your UI
            }
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        return LinkIO.shared.handleUniversalLink(url: url)
    }
}
```

### 2. Add Associated Domains

In Xcode:

1. Target → Signing & Capabilities
2. Add "Associated Domains"
3. Add: `applinks:yourdomain.com`

### 3. Handle Deep Links

```swift
LinkIO.shared.setDeepLinkHandler { deepLink in
    print("URL: \(deepLink.url)")
    print("Params: \(deepLink.params)")
    print("Deferred: \(deepLink.isDeferred)")
}
```

## 📚 API Reference

### Configuration

```swift
let config = LinkIOConfig(
    domain: "yourdomain.com",
    backendURL: "https://yourdomain.com",
    autoCheckPendingLinks: true
)
LinkIO.shared.configure(config: config)
```

### Handle Universal Links

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard let url = userActivity.webpageURL else { return false }
    return LinkIO.shared.handleUniversalLink(url: url)
}
```

### Track Referrals

```swift
LinkIO.shared.trackReferral(
    referralCode: "ABC123",
    userId: "user123",
    metadata: ["source": "ios"]
)
```

### Manual Check for Deferred Links

```swift
LinkIO.shared.checkPendingLink()
```

## 🔗 Related Packages

- **Backend**: [LinkIO-Backend](https://github.com/pt-nakul-sharma/LinkIO-Backend)
- **Android**: [LinkIO-Android](https://github.com/pt-nakul-sharma/LinkIO-Android)
- **React Native**: [LinkIO-React-Native](https://github.com/pt-nakul-sharma/LinkIO-React-Native)

## 🛠️ Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 15.0+

## 📄 License

MIT

## 🤝 Contributing

Contributions are welcome! Please read the [contributing guidelines](CONTRIBUTING.md) first.

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!
