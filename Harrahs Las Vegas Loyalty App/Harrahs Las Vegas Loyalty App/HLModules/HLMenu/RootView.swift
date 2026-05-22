//
//  RootView.swift
//  Harrahs Las Vegas Loyalty App
//
//


import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit


// MARK: - Root

struct RootView: View {
    @StateObject private var viewModel = HarrahsViewModel()

    var body: some View {
        NavigationStack {
            MainTabView(viewModel: viewModel)
        }
    }
}

#Preview(body: {
    RootView()
})
