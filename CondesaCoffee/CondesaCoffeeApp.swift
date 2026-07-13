import SwiftUI

#if canImport(FirebaseCore)
  import FirebaseCore
#endif

@main
struct CondesaCoffeeApp: App {
  @StateObject private var appState = AppState()

  init() {
    #if canImport(FirebaseCore)
      if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
        FirebaseApp.configure()
      }
    #endif
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(appState)
        .preferredColorScheme(.dark)
        .onOpenURL { appState.handle(url: $0) }
    }
  }
}
