//  AllAboutCatsApp.swift

import SwiftUI

@main
struct AllAboutCatsApp: App {
    init() {
        let key = Bundle.main.object(forInfoDictionaryKey: "CAT_API_KEY") as? String
        print("API Key loaded: \(key != nil ? "✅ \(key)" : "❌ MISSING")")
    }

    var body: some Scene {
        WindowGroup {
            CatsListView()
        }
    }
}
