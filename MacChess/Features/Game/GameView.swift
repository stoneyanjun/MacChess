import SwiftUI
import ComposableArchitecture

struct GameView: View {
    let store: StoreOf<GameFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 12) {

                // --- Board only ---
                BoardView(store: store)
                    .frame(width: 640, height: 640)
                    .border(Color(NSColor.separatorColor), width: 1)

                // --- Controls ---
                HStack(spacing: 16) {
                    Toggle("Human vs AI", isOn: viewStore.binding(
                        get: \.isHumanVsAI,
                        send: GameAction.toggleHumanVsAI
                    ))
                    .frame(width: 160)

                    Toggle("AI plays White", isOn: viewStore.binding(
                        get: \.isAIPlayingWhite,
                        send: GameAction.toggleAIPlayingWhite
                    ))
                    .frame(width: 160)

                    Button {
                        viewStore.send(.undo)
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)

                    Button {
                        viewStore.send(.restart)
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.bottom, 10)
            }
            // 核心：横向按内容定宽度
            .fixedSize(horizontal: true, vertical: false)
            // 背景你要的话可以留，也可以先注释掉试试看区别
            .background(Color(NSColor.windowBackgroundColor))
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}
