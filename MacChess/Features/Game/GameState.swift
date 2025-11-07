//
//  GameState.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import Foundation

/// The TCA-managed state for the Game feature.
/// Wraps the domain-level `GameStatus` and adds UI/turn information.
struct GameState: Equatable, Sendable {

    // MARK: - Domain model
    /// The current chessboard and game status.
    var gameStatus: GameStatus = GameStatus()

    // MARK: - Gameplay control
    /// Whose turn it is to move (white starts first).
    var currentTurn: PieceColor = .white

    // MARK: - UI interaction
    /// The currently selected square, if any.
    var selectedSquare: Square?

    /// The valid target squares for the selected piece.
    var highlightSquares: [Square] = []

    /// Whether to flash or show an invalid move indicator.
    var invalidMoveFlash: Bool = false

    // MARK: - Initialization
    init() {
        self.gameStatus = GameStatus()
        self.currentTurn = .white
        self.selectedSquare = nil
        self.highlightSquares = []
        self.invalidMoveFlash = false
    }
}
