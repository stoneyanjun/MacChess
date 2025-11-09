//
//  Square.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation

/// Represents a coordinate on the chessboard (file a–h, rank 1–8).
struct Square: Codable, Hashable, Equatable, Sendable {
    let file: Int   // 0 = a, 7 = h
    let rank: Int   // 0 = 1, 7 = 8

    init(file: Int, rank: Int) {
        self.file = file
        self.rank = rank
    }

    /// Initialize from notation like "e2"
    init?(notation: String) {
        guard notation.count == 2 else { return nil }
        let chars = Array(notation.lowercased())
        guard let fileChar = chars.first,
              let rankChar = chars.last,
              fileChar >= "a", fileChar <= "h",
              rankChar >= "1", rankChar <= "8"
        else { return nil }

        self.file = Int(fileChar.asciiValue! - Character("a").asciiValue!)
        self.rank = Int(rankChar.asciiValue! - Character("1").asciiValue!)
    }

    /// Convert to algebraic notation like "e2"
    var notation: String {
        let fileChar = Character(UnicodeScalar(file + 97)!)
        let rankChar = Character(UnicodeScalar(rank + 49)!)
        return "\(fileChar)\(rankChar)"
    }

    /// Whether this square is dark (a1 = dark)
    var isDark: Bool {
        (file + rank).isMultiple(of: 2)
    }
}
