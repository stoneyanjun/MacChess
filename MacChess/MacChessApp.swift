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
            // 这里不要再 .frame(maxWidth: .infinity) 之类
        }
        // 关键 1：窗口大小跟随内容大小，用户不能拉大
        .windowResizability(.contentSize)
        // 关键 2：给个初始窗口大小（宽度 640，高度稍微大于棋盘）
        .defaultSize(width: 680, height: 720)
        // 可选：默认居中
        .defaultPosition(.center)
    }
}

