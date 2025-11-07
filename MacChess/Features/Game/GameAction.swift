//
//  GameAction.swift
//  MacChess
//
//  Created by stone on 2025/11/08.
//

import Foundation

/// All user and system actions handled by the Game feature.
/// Stage Two adds piece selection, movement, and validation feedback.
enum GameAction: Equatable, Sendable {

    // MARK: - Lifecycle
    /// Triggered when the GameView appears (initial setup).
    case onAppear

    // MARK: - User interaction
    /// User clicked or tapped a square.
    case selectSquare(Square)

    /// Internal: player attempted to move a piece.
    case attemptMove(from: Square, to: Square)

    /// Internal: move accepted and applied to the board.
    case moveAccepted(from: Square, to: Square)

    /// Internal: invalid move attempt (rejected).
    case invalidMove(from: Square, to: Square)

    // MARK: - Game control
    /// Undo the last move (future feature).
    case undo

    /// Restart the game (reset to standard setup).
    case restart

    // MARK: - System or error handling
    /// Log or display internal errors.
    case internalError(String)
}
