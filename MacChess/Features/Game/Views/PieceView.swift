//
//  PieceView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI

struct PieceView: View {
    let piece: Piece
    let isFlipped: Bool   // keep for future use if needed

    var body: some View {
        Text(piece.symbol)
            .font(.system(size: 36))
            // 🧩 Remove rotation — always upright
            .rotationEffect(.degrees(0))
    }
}
