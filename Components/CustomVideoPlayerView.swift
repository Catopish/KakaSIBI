//
//  CustomVideoPlayerView.swift
//  MachineLearningChallenge
//
//  Created by Lin Dan Christiano on 16/06/25.
//

//
//import SwiftUI
//import AVKit
//
//public struct CustomVideoPlayerView: View {
//    public let url: URL
//    
//    @State private var player: AVPlayer = AVPlayer()
//    @State private var playCount: Int = 0
//    @State private var showReplayButton = false
//    
//    public init(url: URL) {
//           self.url = url
//       }
//
//    // Observing player end
//    private var playerObserver: Any?
//    
//    public var body: some View {
//        ZStack {
//            VideoPlayer(player: player)
//                .disabled(true) // matikan control default
//                .onAppear {
//                    setupPlayer()
//                    player.play()
//                }
//                .onDisappear {
//                    player.pause()
//                    removeObserver()
//                }
//            
//            if showReplayButton {
//                Button(action: {
//                    playCount = 0
//                    showReplayButton = false
//                    player.seek(to: .zero)
//                    player.play()
//                }) {
//                    Image(systemName: "gobackward")
//                        .resizable()
//                        .frame(width: 60, height: 60)
//                        .foregroundColor(.white)
//                        .background(Circle().fill(Color.black.opacity(0.6)))
//                }
//            }
//        }
//    }
//    
//    // MARK: - Player Setup & Observer
//    private func setupPlayer() {
//        player.replaceCurrentItem(with: AVPlayerItem(url: url))
//        player.actionAtItemEnd = .none
//        
//        removeObserver() // Remove old observer if any
//        
//        NotificationCenter.default.addObserver(
//            forName: .AVPlayerItemDidPlayToEndTime,
//            object: player.currentItem,
//            queue: .main
//        ) { _ in
//            playCount += 1
//            if playCount >= 2 {
//                player.pause()
//                showReplayButton = true
//            } else {
//                player.seek(to: .zero)
//                player.play()
//            }
//        }
//    }
//    
//    private func removeObserver() {
//        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//    }
//}

import SwiftUI
import AVFoundation
import AVKit

struct CustomVideoPlayerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        player.isMuted = false
        player.actionAtItemEnd = .none

        view.wantsLayer = true
        view.layer?.addSublayer(playerLayer)

        // ⬇️ Autoresizing mask agar layer ikut ukuran view
        playerLayer.frame = view.bounds
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

        context.coordinator.playerLayer = playerLayer
        return view
    }


    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.playerLayer?.frame = nsView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

struct VideoContainerView: View {
    let videoURL: URL
    @State private var player: AVPlayer
    @State private var playCount: Int = 0
    @State private var showReplayButton: Bool = false

    init(videoURL: URL) {
        self.videoURL = videoURL
        self._player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        ZStack {
            CustomVideoPlayerView(player: player)
                .onAppear {
                    player.seek(to: .zero)
                    player.play()
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                        playCount += 1
                        if playCount < 2 {
                            player.seek(to: .zero)
                            player.play()
                        } else {
                            showReplayButton = true
                        }
                    }
                }

            if showReplayButton {
                Button(action: {
                    playCount = 0
                    showReplayButton = false
                    player.seek(to: .zero)
                    player.play()
                }) {
                    Image(systemName: "gobackward")
                        .font(.system(size: 48))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
            }
        }
    }
}
