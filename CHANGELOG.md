# Changelog

## [2.0.0] - 2026-07-28

Swift 6 release. Requires Xcode 16+ / a Swift 6 toolchain. Consumers on older
toolchains should stay on the 1.1.x line (which carries the same pending-link fix).

### Changed

- Swift 6 language mode: `LinkIO` is now `@MainActor`-isolated and `DeepLinkData` /
  `LinkIOConfig` conform to `Sendable`, eliminating data races under strict concurrency.
  Public API is unchanged.
- `Package.swift` declares `swift-tools-version:6.0` and `swiftLanguageModes: [.v5, .v6]`;
  podspec `swift_version` is `6.0`.

### Requires

- Xcode 16+ / Swift 6 toolchain.

## [1.1.1] - 2026-07-28

### Fixed

- Handle empty (`{}`) pending-link responses without logging a decode error

## [1.2.0] - 2026-02-03

### Added

- Documentation for generic `/link` endpoint with any params
- Example code for handling multiple link types (referral, profile, product)

### Changed

- Updated deep link handler examples to show type-based routing

## [1.1.0] - 2026-02-03

### Fixed

- Removed hardcoded `/api/` prefix from URL construction
- `backendURL` now controls the full API path (including version prefix)

### Changed

- SDK now appends `pending-link/` and `track-referral` directly to `backendURL`
- Updated documentation with correct `backendURL` configuration examples

### Migration

If you were using:

```swift
backendURL: "https://api.example.com"
```

Update to include your API version:

```swift
backendURL: "https://api.example.com/api/v1/"  // Trailing slash required
```

## [1.0.0] - 2026-02-03

### Added

- Initial release
- Universal Links support
- Deferred deep linking
- Referral tracking
- Swift Package Manager support
- CocoaPods support
