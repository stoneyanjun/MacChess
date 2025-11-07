//
//  GameAction.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

extension GameFeature {
    enum Action: Equatable {
        case selectSquare(Square)
        case move(from: Square, to: Square)
        case reset
    }
}
