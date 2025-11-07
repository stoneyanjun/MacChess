//
//  SuggestionView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI

/// Displays Stockfish's current best move suggestion.
struct SuggestionView: View {
    let suggestion: EngineSuggestion?
    let isAnalyzing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestion")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            if isAnalyzing {
                ProgressView("Analyzing...")
                    .progressViewStyle(.linear)
                    .frame(maxWidth: .infinity)
            } else if let suggestion = suggestion {
                Text("\(suggestion.bestMove)")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.vertical, 4)
            } else {
                Text("No suggestion yet.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .frame(minWidth: 180, maxWidth: 220, maxHeight: 640)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}
