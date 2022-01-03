import SwiftUI
import WaniKani

struct ProfileView: View {
    @EnvironmentObject private var services: Services
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Text("Hello")
    }

    class ViewModel: ObservableObject {
        
    }
}
