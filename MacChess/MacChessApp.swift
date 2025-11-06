//
//  MacChessApp.swift
//  MacChess
//
//  Created by stone on 2025/11/6.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
//
//  MacChessApp.swift
//  MacChess
//
//  Created by stone on 2025/11/06.
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
            .frame(width: 540, height: 560)
        }
    }
}
