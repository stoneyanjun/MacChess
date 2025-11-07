//
//  EngineSuggestion.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation

/// Represents Stockfish’s analyzed output for a position.
struct EngineSuggestion: Equatable, Sendable {
    /// Example: "e7e5"
    let bestMove: String

    /// Optional principal variation (main line of play)
    let pv: [String]

    /// Evaluation score in centipawns (positive = white better)
    let score: Int?

    /// Search depth used for this suggestion
    let depth: Int
}
