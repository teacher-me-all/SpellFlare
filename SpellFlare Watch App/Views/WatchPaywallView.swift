//
//  WatchPaywallView.swift
//  SpellFlare Watch App
//
//  Paywall shown when trying to access premium levels (6+) without purchase.
//

import SwiftUI

struct WatchPaywallView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)

                // Title
                Text("Unlock All Levels")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Message
                Text("Purchase \"Unlock Watch\" on iPhone to access levels 6-50")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
                    .frame(height: 8)

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(.cyan)
                        Text("Open SpellFlare on iPhone")
                            .font(.caption2)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(.cyan)
                        Text("Go to Settings")
                            .font(.caption2)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.cyan)
                        Text("Tap \"Unlock Watch Levels\"")
                            .font(.caption2)
                    }
                }
                .foregroundColor(.white.opacity(0.8))

                Spacer()
                    .frame(height: 12)

                // OK button
                Button {
                    dismiss()
                } label: {
                    Text("OK")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.cyan)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.9),
                    Color(red: 0.3, green: 0.15, blue: 0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    WatchPaywallView()
}
