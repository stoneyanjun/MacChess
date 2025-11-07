//
//  GameView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI
import ComposableArchitecture

/// The main chessboard screen.
/// Stage 5.3: adds SuggestionView (left) and MoveHistoryView (right)
struct GameView: View {
    let store: StoreOf<GameFeature>

    private let fileLabels = ["a","b","c","d","e","f","g","h"]
    private let rankLabels = Array(1...8)

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {

                // --- 1️⃣ Turn indicator ---
                Text("\(viewStore.currentTurn.displayName)'s turn")
                    .font(.headline)
                    .foregroundColor(viewStore.currentTurn == .white ? .primary : .gray)

                // --- 2️⃣ Main play area ---
                HStack(alignment: .top, spacing: 12) {

                    // === Left section: Stockfish suggestion ===
                    SuggestionView(
                        suggestion: viewStore.lastEngineSuggestion,
                        isAnalyzing: viewStore.isAnalyzing
                    )

                    // === Middle section: Board + labels ===
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            // Rank numbers (1–8)
                            VStack(spacing: 0) {
                                ForEach(rankLabels.reversed(), id: \.self) { rank in
                                    Text("\(rank)")
                                        .font(.system(size: 18, weight: .medium))
                                        .frame(width: 20, height: 80)
                                        .foregroundColor(.secondary)
                                }
                            }

                            // Interactive chessboard
                            BoardView(store: store)
                                .frame(width: 640, height: 640)
                                .border(Color(NSColor.separatorColor), width: 1)
                        }

                        // File letters (a–h)
                        HStack(spacing: 0) {
                            Spacer().frame(width: 20)
                            ForEach(fileLabels, id: \.self) { file in
                                Text(file)
                                    .font(.system(size: 18, weight: .medium))
                                    .frame(width: 80)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // === Right section: Move history ===
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Move History")
                            .font(.headline)
                            .padding(.top, 4)
                        Divider()
                        MoveHistoryView(moves: viewStore.moveHistory)
                            .frame(minWidth: 180, maxWidth: 220, maxHeight: 640)
                    }
                    .frame(height: 640)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .shadow(radius: 1)
                }

                // --- 3️⃣ Bottom controls ---
                HStack {
                    Spacer()
                    Button {
                        viewStore.send(.restart)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.top, 8)
            }
            .padding(16)
            .background(Color(NSColor.windowBackgroundColor))
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
