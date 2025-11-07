//
//  SquareView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI
import ComposableArchitecture

/// Represents a single square on the chessboard.
/// Stage Two: adds highlights, selection feedback, and click handling.
struct SquareView: View {
    let store: StoreOf<GameFeature>
    let square: Square
    let piece: Piece?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                // --- 1️⃣ Base square background ---
                Rectangle()
                    .fill(color(for: square))
                    .aspectRatio(1, contentMode: .fit)

                // --- 2️⃣ Highlights ---
                if viewStore.invalidMoveFlash && viewStore.selectedSquare == square {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 4)
                } else if viewStore.selectedSquare == square {
                    Rectangle()
                        .stroke(Color.yellow, lineWidth: 4)
                } else if viewStore.highlightSquares.contains(square) {
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 3)
                }

                // --- 3️⃣ Piece overlay ---
                if let piece = piece {
                    PieceView(piece: piece)
                }
            }
            // --- 4️⃣ Handle click/tap ---
            .onTapGesture {
                viewStore.send(.selectSquare(square))
            }
        }
    }

    /// Determines the background color (a1 is dark).
    private func color(for square: Square) -> Color {
        square.isDark
            ? Color(NSColor(calibratedWhite: 0.35, alpha: 1.0))
            : Color(NSColor(calibratedWhite: 0.85, alpha: 1.0))
    }
}
