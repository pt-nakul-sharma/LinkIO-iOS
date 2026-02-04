# LinkIO iOS

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-brightgreen.svg)](https://cocoapods.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0+-blue.svg)](https://developer.apple.com/ios/)

Self-hosted deep linking SDK for iOS. Open-source alternative to Branch.io.

## 🚀 Installation

### Swift Package Manager (Recommended)

**In Xcode:**

1. File → Add Packages...
2. Enter: `https://github.com/pt-nakul-sharma/LinkIO-iOS.git`
3. Select version rule: "Up to Next Major" starting from 1.1.0
4. Click "Add Package"

**In Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/pt-nakul-sharma/LinkIO-iOS.git", from: "1.1.0")
]
```

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'LinkIO', :git => 'https://github.com/pt-nakul-sharma/LinkIO-iOS.git', :tag => '1.1.0'
```

Or for the latest version:

```ruby
pod 'LinkIO', :git => 'https://github.com/pt-nakul-sharma/LinkIO-iOS.git'
```

Then run:

```bash
pod install
```

## 📱 Quick Start

### 1. Configure in AppDelegate

```swift
import UIKit
import LinkIO

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Configure your backend URL with API version
    let apiVersion = "api/v1/"  // Match your backend route structure
    let baseURL = "https://api.yourdomain.com/"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let config = LinkIOConfig(
            domain: "yourdomain.com",
            backendURL: baseURL + apiVersion,  // Full path: https://api.yourdomain.com/api/v1/
            appScheme: "yourapp"  // Custom URL scheme (e.g., yourapp://)
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

    // Handle params directly - no "type" field needed
    if let referralCode = deepLink.params["referralCode"] {
        // Handle referral
    } else if let userId = deepLink.params["userId"] {
        // Show user profile
    } else if let carId = deepLink.params["carId"] {
        // Show car details (Ejaro)
    }
}
```

### Deep Link URL Format

Use a generic `/link` endpoint with query params:

```
https://rokart.in/link?referralCode=ABC123
https://speekfeed.in/link?userId=456
https://ejaro.com/link?carId=789
```

## 📚 API Reference

### Configuration

```swift
// backendURL should include the full API path
// SDK appends: pending-link/, track-referral
let config = LinkIOConfig(
    domain: "yourdomain.com",
    backendURL: "https://api.yourdomain.com/api/v1/",  // Trailing slash required
    appScheme: "yourapp",  // Custom URL scheme (e.g., yourapp://)
    autoCheckPendingLinks: true
)
LinkIO.shared.configure(config: config)

// SDK will call:
// - https://api.yourdomain.com/api/v1/pending-link/:deviceId
// - https://api.yourdomain.com/api/v1/track-referral
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

## 📲 Complete iOS Example

**Complete AppDelegate setup:**

```swift
import UIKit
import LinkIO

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize LinkIO
        let config = LinkIOConfig(
            domain: "yourdomain.com",
            backendURL: "https://api.yourdomain.com/api/v1/",
            appScheme: "yourapp"  // Custom URL scheme (e.g., yourapp://)
        )
        LinkIO.shared.configure(config: config)

        // Handle deep links
        LinkIO.shared.setDeepLinkHandler { deepLink in
            self.handleDeepLink(deepLink)
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        return LinkIO.shared.handleUniversalLink(url: url)
    }

    private func handleDeepLink(_ deepLink: DeepLinkData) {
        // Navigate based on params
        if let referralCode = deepLink.params["referralCode"] {
            showReferralScreen(code: referralCode)
        } else if let productId = deepLink.params["productId"] {
            showProductDetails(id: productId)
        } else if let userId = deepLink.params["userId"] {
            showUserProfile(id: userId)
        }
    }
}
```

**SwiftUI App setup:**

```swift
import SwiftUI
import LinkIO

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    LinkIO.shared.handleUniversalLink(url: url)
                }
        }
    }
}
```

## � Related Packages

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
