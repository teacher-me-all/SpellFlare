//
//  ParentGateView.swift
//  spelling-bee iOS App
//
//  Parent gate to prevent accidental purchases by children.
//  Requires solving a simple math problem that adults can solve.
//

import SwiftUI

struct ParentGateView: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: () -> Void

    @State private var num1: Int = 0
    @State private var num2: Int = 0
    @State private var userAnswer: String = ""
    @State private var showError: Bool = false
    @State private var attempts: Int = 0

    private let maxAttempts = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)

                // Title
                Text("Parent Verification")
                    .font(.title2)
                    .fontWeight(.bold)

                // Description
                Text("To continue, please solve this math problem.\nThis helps ensure a parent is present.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // Math problem
                VStack(spacing: 16) {
                    Text("What is \(num1) × \(num2)?")
                        .font(.title)
                        .fontWeight(.semibold)

                    TextField("Enter answer", text: $userAnswer)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .frame(width: 150)

                    if showError {
                        Text("Incorrect answer. Please try again.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    if attempts >= maxAttempts {
                        Text("Too many attempts. Please try again later.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 20)

                // Submit button
                Button {
                    checkAnswer()
                } label: {
                    Text("Verify")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(attempts >= maxAttempts ? Color.gray : Color.purple)
                        .cornerRadius(12)
                }
                .disabled(userAnswer.isEmpty || attempts >= maxAttempts)
                .padding(.horizontal, 40)

                Spacer()

                // Cancel option
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                generateProblem()
            }
        }
    }

    private func generateProblem() {
        // Generate a multiplication problem that's easy for adults but harder for young children
        num1 = Int.random(in: 6...12)
        num2 = Int.random(in: 4...9)
    }

    private func checkAnswer() {
        let correctAnswer = num1 * num2

        if let answer = Int(userAnswer), answer == correctAnswer {
            // Correct - parent verified
            // Call onSuccess first, then dismiss after a short delay
            onSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        } else {
            // Incorrect
            attempts += 1
            showError = true
            userAnswer = ""

            if attempts < maxAttempts {
                // Generate a new problem
                generateProblem()
            }
        }
    }
}

// MARK: - Preview
struct ParentGateView_Previews: PreviewProvider {
    static var previews: some View {
        ParentGateView(onSuccess: {})
    }
}
