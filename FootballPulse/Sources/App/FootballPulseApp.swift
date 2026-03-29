import SwiftUI

@main
struct FootballPulseApp: App {
    @State private var environment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(environment)
        }
    }
}
