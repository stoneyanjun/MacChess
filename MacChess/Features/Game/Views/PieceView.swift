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
        if let image = NSImage(named: NSImage.Name(piece.assetName)) {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .padding(4)
                .accessibilityLabel(Text("\(piece.color.displayName) \(piece.type.rawValue)"))
        } else {
            // Fallback to Unicode symbol if asset missing
            Text(piece.symbol)
                .font(.system(size: 28))
                .padding(4)
                .accessibilityLabel(Text("\(piece.color.displayName) \(piece.type.rawValue)"))
        }
    }
}
