//
//  PieceView.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI

struct PieceView: View {
    let piece: Piece

    var body: some View {
        Text(piece.symbol)
            .font(.system(size: 36))
    }
}
