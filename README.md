# Condesa Coffee iOS

A native SwiftUI customer ordering and barista queue app for Condesa Coffee in Atlanta's Old Fourth Ward.

## Open and run

1. Open `CondesaCoffee.xcodeproj` in Xcode 16 or newer.
2. Allow Swift Package Manager to resolve Firebase.
3. Build on an iOS 17+ simulator. The app uses placeholder menu and order data until Firebase is configured.

## Firebase

Add the `beam-home` project's `GoogleService-Info.plist` to the `CondesaCoffee` target. Firebase startup is intentionally guarded, so the app runs without this file. Firestore expects `menuItems` and `orders` collections matching the project brief.

## Apple Pay

Replace the placeholder merchant ID `merchant.com.ragnexus.condesacoffee` in `CheckoutView.swift` and `CondesaCoffee.entitlements` with the production merchant ID, then enable Apple Pay for the App ID and provisioning profile. The manual card form is a UI placeholder and must be connected to a PCI-compliant payment provider before release.

## Deep link

The URL scheme is registered for links such as `condesa://order?table=12` or `condesa://order?room=204`. Either parameter pre-fills the order summary.

The checked-in `project.yml` is the XcodeGen source of truth. Run `xcodegen generate` after changing project settings.
