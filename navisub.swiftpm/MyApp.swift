import SwiftUI

@main
@available(iOS 17.0, *)
struct MyApp: App {
    let db = try! Database()
    let env = EnvObjects()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(db)
                .environmentObject(env)
        }
    }
}

