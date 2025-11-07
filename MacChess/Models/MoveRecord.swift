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

extension MoveRecord {
    var uciString: String {
        let files = ["a","b","c","d","e","f","g","h"]
        let fromStr = "\(files[from.col])\(from.row + 1)"
        let toStr = "\(files[to.col])\(to.row + 1)"
        return fromStr + toStr
    }
}
