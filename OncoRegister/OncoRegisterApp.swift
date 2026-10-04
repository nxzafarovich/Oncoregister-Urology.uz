import SwiftUI

@main
struct OncoRegisterApp: App {
    @StateObject private var language = LanguageStore()
    @StateObject private var db = DatabaseManager.shared

    var body: some Scene {
        WindowGroup("Onco Register") {
            ContentView()
                .environmentObject(language)
                .environmentObject(db)
                .frame(minWidth: 1050, minHeight: 720)
                .onAppear {
                    do { try db.start() }
                    catch { NSAlert(error: error).runModal() }
                }
        }
        .windowStyle(.titleBar)
    }
}
