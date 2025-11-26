//
//  SquareView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI
import ComposableArchitecture

/// A single cell on the board (with piece, highlights, and interaction).
struct SquareView: View {
    let store: StoreOf<GameFeature>
    let square: Square
    let piece: Piece?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                // --- Base square background (a1 = dark) ---
                Rectangle()
                    .fill(color(for: square))
                    .aspectRatio(1, contentMode: .fit)

                // --- Highlight last move destination ---
                if viewStore.lastMoveTo == square {
                    Rectangle()
                        .fill(Color.yellow.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                }

                // --- Highlight last move source ---
                if viewStore.lastMoveFrom == square {
                    Rectangle()
                        .fill(Color.purple.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                }

                // --- Selection / Legal move highlights ---
                if viewStore.invalidMoveFlash && viewStore.selectedSquare == square {
                    Rectangle().stroke(Color.red, lineWidth: 4)
                } else if viewStore.selectedSquare == square {
                    Rectangle().stroke(Color.yellow, lineWidth: 4)
                } else if viewStore.highlightSquares.contains(square) {
                    Rectangle().stroke(Color.blue, lineWidth: 3)
                }

                // --- Piece ---
                if let piece = piece {
                    PieceView(piece: piece)
                }
            }
            .onTapGesture {
                viewStore.send(.selectSquare(square))
            }
        }
    }

    private func color(for square: Square) -> Color {
        square.isDark
            ? Color(NSColor(calibratedWhite: 0.35, alpha: 1.0))
            : Color(NSColor(calibratedWhite: 0.85, alpha: 1.0))
    }
}
