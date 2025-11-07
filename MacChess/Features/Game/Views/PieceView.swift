//
//  PieceView.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import SwiftUI

/// Displays a single chess piece image or fallback symbol.
struct PieceView: View {
    let piece: Piece

    var body: some View {
        // Try to load the image asset; fallback to text symbol if missing
        if let image = NSImage(named: piece.assetName) {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .padding(4)
                .accessibilityLabel(Text("\(piece.color.displayName) \(piece.type.rawValue)"))
        } else {
            Text(piece.symbol)
                .font(.system(size: 28))
                .padding(4)
        }
    }
}
