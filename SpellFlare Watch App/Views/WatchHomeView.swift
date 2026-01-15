//
//  WatchHomeView.swift
//  SpellFlare Watch App
//
//  Home screen with level selection and progress display.
//

import SwiftUI

struct WatchHomeView: View {
    @EnvironmentObject var appState: WatchAppState
    @EnvironmentObject var syncHelper: WatchSyncHelper

    @State private var selectedLevel: Int = 1

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("SpellFlare")
                    .font(.headline)
                    .foregroundColor(.cyan)

                Spacer()

                // Sync indicator
                if syncHelper.isPhoneReachable {
                    Image(systemName: "iphone")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "iphone.slash")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Grade display
            Text("Grade \(syncHelper.profile?.grade ?? 1)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            // Level selection with progress ring
            ZStack {
                // Progress ring
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progressForCurrentGrade)
                    .stroke(Color.cyan, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                // Level button
                Button {
                    appState.startGame(level: currentLevel)
                } label: {
                    VStack(spacing: 4) {
                        Text("Level")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("\(currentLevel)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Start button
            Button {
                appState.startGame(level: currentLevel)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.cyan)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            // Completed levels count
            Text("\(completedLevelsCount)/50 completed")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            selectedLevel = currentLevel
        }
    }

    // MARK: - Computed Properties

    private var currentLevel: Int {
        syncHelper.profile?.currentLevel ?? 1
    }

    private var completedLevelsCount: Int {
        syncHelper.profile?.completedLevels.count ?? 0
    }

    private var progressForCurrentGrade: Double {
        Double(completedLevelsCount) / 50.0
    }
}

#Preview {
    WatchHomeView()
        .environmentObject(WatchAppState())
        .environmentObject(WatchSyncHelper.shared)
}
