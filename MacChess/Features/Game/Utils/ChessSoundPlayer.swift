//
//  ChessSoundPlayer.swift
//  MacChess
//
//  Created by stone on 2025/11/9.
//

import AVFoundation
/// Simple static audio helper for piece move sound
enum ChessSoundPlayer {
    private static var player: AVAudioPlayer?

    /// 播放棋子落地声
    static func playMoveSound() {
        playSound(named: "move")
    }
    
    static func playCaptureSound() {
        playSound(named: "capture")
    }

    private static func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
