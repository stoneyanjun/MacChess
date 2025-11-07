//
//  GameState.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import Foundation

extension GameFeature {
    struct State: Equatable {
        var board: [[Piece?]] = GameFeature.initialBoard()
        var selectedSquare: Square? = nil
        var currentTurn: PieceColor = .white
        
        var moveHistory: [MoveRecord] = []
        var moveNumber: Int = 1
    }
}
