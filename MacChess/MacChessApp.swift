//
//  MacChessApp.swift
//  MacChess
//
//  Created by stone on 2025/11/7.
//

import SwiftUI
import ComposableArchitecture

@main
struct MacChessApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(
                store: Store(
                    initialState: GameFeature.State(),
                    reducer: { GameFeature() }
                )
            )
        }
    }
}
