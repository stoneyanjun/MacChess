//
//  GameAction.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation

/// All user and system actions handled by the Game feature.
/// Stage 5.1: includes Stockfish engine suggestion support.
enum GameAction: Equatable, Sendable {

    // MARK: - Lifecycle
    /// Triggered when the GameView appears (initial setup).
    case onAppear

    // MARK: - User Interaction
    /// User clicked or tapped a square.
    case selectSquare(Square)

    /// Internal: player attempted to move a piece.
    case attemptMove(from: Square, to: Square)

    /// Internal: move accepted and applied to the board.
    case moveAccepted(from: Square, to: Square)

    /// Internal: invalid move attempt (rejected).
    case invalidMove(from: Square, to: Square)

    // MARK: - Game Control
    /// Undo the last move (future feature).
    case undo

    /// Restart the game (reset to standard setup and clear histories).
    case restart

    // MARK: - Engine Integration (Stage 5.1)
    /// Request Stockfish to analyze the current position and suggest best move.
    case requestEngineSuggestion

    /// Receive Stockfish’s analyzed result.
    case receiveEngineSuggestion(EngineSuggestion?)

    // MARK: - System / Error Handling
    /// Log or display internal errors.
    case internalError(String)
}
