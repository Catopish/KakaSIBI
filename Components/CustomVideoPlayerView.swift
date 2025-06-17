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
    @State private var currentURL: URL

    init(videoURL: URL) {
        self.videoURL = videoURL
        self._player = State(initialValue: AVPlayer(url: videoURL))
        self._currentURL = State(initialValue: videoURL)
    }

    var body: some View {
        ZStack {
            CustomVideoPlayerView(player: player)
                .onAppear {
                    setupPlayer()
                }
                .onChange(of: videoURL) { newURL in
                    // Update player when URL changes
                    if newURL != currentURL {
                        updatePlayer(with: newURL)
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
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func setupPlayer() {
        player.seek(to: .zero)
        player.play()
        addPlayerObserver()
    }
    
    private func updatePlayer(with newURL: URL) {
        // Remove old observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        // Update player with new URL
        let newItem = AVPlayerItem(url: newURL)
        player.replaceCurrentItem(with: newItem)
        currentURL = newURL
        
        // Reset states
        playCount = 0
        showReplayButton = false
        
        // Setup new player
        setupPlayer()
    }
    
    private func addPlayerObserver() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            playCount += 1
            if playCount < 2 {
                player.seek(to: .zero)
                player.play()
            } else {
                showReplayButton = true
            }
        }
    }
}
