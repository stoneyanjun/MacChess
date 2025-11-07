//
//  GameView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI
import ComposableArchitecture

/// The main chessboard screen.
/// Stage Two: connects the interactive BoardView and adds turn indicator + labels.
struct GameView: View {
    let store: StoreOf<GameFeature>

    // File (column) and rank (row) labels
    private let fileLabels = ["a","b","c","d","e","f","g","h"]
    private let rankLabels = Array(1...8)

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 8) {
                // --- Turn indicator ---
                Text("\(viewStore.currentTurn.displayName)'s turn")
                    .font(.headline)
                    .foregroundColor(viewStore.currentTurn == .white ? .primary : .gray)

                // --- Main board area with rank labels on left ---
                HStack(spacing: 4) {
                    // Rank numbers (1–8)
                    VStack(spacing: 0) {
                        ForEach(rankLabels.reversed(), id: \.self) { rank in
                            Text("\(rank)")
                                .font(.system(size: 12, weight: .medium))
                                .frame(width: 20, height: 80)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Interactive chessboard (640×640 fixed)
                    BoardView(store: store)
                        .frame(width: 640, height: 640)
                }

                // --- File letters (a–h) ---
                HStack(spacing: 0) {
                    Spacer().frame(width: 20)
                    ForEach(fileLabels, id: \.self) { file in
                        Text(file)
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 80)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
