//
//  Square.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import Foundation

/// Represents a coordinate on the chessboard (file + rank).
struct Square: Hashable, Codable, Sendable {
    /// File index (0–7) → a–h.
    let file: Int
    /// Rank index (0–7) → 1–8.
    let rank: Int

    /// Standard algebraic notation, e.g. "a1", "e4".
    var notation: String {
        let fileLetter = Square.fileLetters[file]
        let rankNumber = rank + 1
        return "\(fileLetter)\(rankNumber)"
    }

    /// Convenience constants for file → letter mapping.
    static let fileLetters: [String] = ["a","b","c","d","e","f","g","h"]

    /// Returns whether the square should be dark or light,
    /// according to chess convention (a1 = dark).
    var isDark: Bool {
        (file + rank).isMultiple(of: 2) == false
    }
}
