import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

#Preview(body: {
    RootView()
})
// MARK: - Root

struct RootView: View {
    @StateObject private var viewModel = HarrahsViewModel()

    var body: some View {
        NavigationStack {
            MainTabView(viewModel: viewModel)
        }
    }
}