import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var services: Services
    @State private var showProfileScreen = false

    var body: some View {
        NavigationView {
            switch services.authState {
            case .unknown:
                ProgressView()
            case .authenticated:
                HomeView()
                    .toolbar(content: toolbar)
                    .sheet(isPresented: $showProfileScreen) {
                        ProfileView()
                    }
            case .notAuthenticated:
                LoginView()
            }
        }
    }

    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(
                action: {
                    showProfileScreen = true
                },
                label: {
                    Label("Profile", systemImage: "gear")
                }
            )
        }
    }
}
