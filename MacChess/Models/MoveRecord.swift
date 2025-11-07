//
//  MoveRecord.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation

struct MoveRecord: Identifiable, Equatable {
    let id = UUID()
    let moveNumber: Int
    let color: PieceColor
    let from: Square
    let to: Square
    let notation: String
}
