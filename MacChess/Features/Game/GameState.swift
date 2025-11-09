//
//  GameState.swift
//  MacChess
//
//  Created by stone on 2025/11/07.
//

import Foundation

/// The TCA-managed state for the Game feature.
/// Stage 5.4: adds Human vs AI mode flags to Stage 5.1.
struct GameState: Equatable, Sendable {
    
    var lastMoveTo: Square?
    
    // MARK: - Domain model
    /// The current chessboard and game status.
    var gameStatus: GameStatus = GameStatus()

    // MARK: - Gameplay control
    /// Whose turn it is to move (white starts first).
    var currentTurn: PieceColor = .white

    /// The current full-move index (increments after each black move).
    /// Starts from 1 per chess convention.
    var moveIndex: Int = 1

    // MARK: - UI interaction
    /// The currently selected square, if any.
    var selectedSquare: Square?

    /// The valid target squares for the selected piece.
    var highlightSquares: [Square] = []

    /// Whether to flash or show an invalid-move indicator.
    var invalidMoveFlash: Bool = false

    // MARK: - Move history
    /// List of all recorded moves (in order), e.g. "e2e4", "e7e5".
    var moveHistory: [MoveRecord] = []

    // MARK: - Engine integration (Stage 5.1)
    /// Latest Stockfish suggestion result.
    var lastEngineSuggestion: EngineSuggestion?

    /// Indicates whether an engine analysis is currently running.
    var isAnalyzing: Bool = false

    // MARK: - Human vs AI mode (Stage 5.4)
    /// Indicates whether the game is Human vs AI (true) or Human vs Human (false).
    var isHumanVsAI: Bool = false

    /// Indicates whether the AI controls the white pieces (true) or black pieces (false).
    var isAIPlayingWhite: Bool = false

    // MARK: - Initialization
    init() {
        self.gameStatus = GameStatus()
        self.currentTurn = .white
        self.moveIndex = 1
        self.selectedSquare = nil
        self.highlightSquares = []
        self.invalidMoveFlash = false
        self.moveHistory = []
        self.lastEngineSuggestion = nil
        self.isAnalyzing = false
        self.isHumanVsAI = false
        self.isAIPlayingWhite = false
    }
}
