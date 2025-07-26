//
//  LoadingOverlay.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//

import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                Text("Loading user profile...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .transition(.opacity)
        .zIndex(1)
    }
}
