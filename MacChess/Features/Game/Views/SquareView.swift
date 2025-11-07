//
//  SquareView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI

struct SquareView: View {
    let square: Square
    let piece: Piece?
    let isSelected: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color(for: square))
            if isSelected {
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 3)
            }
            if let piece = piece {
                PieceView(piece: piece)
            }
        }
    }
    
    private func color(for square: Square) -> Color {
        let light = Color(nsColor: NSColor.windowBackgroundColor)
        let dark = Color(nsColor: NSColor.controlAccentColor.withSystemEffect(.disabled))
        return (square.row + square.col).isMultiple(of: 2) ? light : dark
    }
}
