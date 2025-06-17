import SwiftUI
import AppKit       // for NSView
import AVFoundation // for AVCaptureSession
import TipKit
import AVKit

struct videoTips: Tip {
    var title: Text  {
        Text("Watch Tutorial First")
    }
    var message: Text? {
        Text("by watching this video first, you can grasp how to do the sign language")
    }
    var image: Image? {
        Image(systemName: "star")
    }
}

struct selectWordsTips: Tip {
    var title: Text  {
        Text("Click Here to change Words")
    }
    var message: Text? {
        Text("Click Here to change Words")
    }
    var image: Image? {
        Image(systemName: "star")
    }
}

struct videoPreviewTips: Tip {
    var title: Text  {
        Text("Peragakan ulang")
    }
    var message: Text? {
        Text("peragakan ulang")
    }
    var image: Image? {
        Image(systemName: "star")
    }
}

struct TestingView: View {
    
    @State private var player = AVPlayer()
    @StateObject private var camera = CameraModel()
    let onBack: () -> Void
    // State untuk mengontrol apakah kartu terbuka atau tertutup
    @State private var isCardOpen: Bool = false
    @State private var selectedWord: String?     // ← track user's choice
    @State private var showOverlay: Bool = false   // show big check
    @State private var showCompletionModal = false
    
    let pronouns = ["Aku", "Kamu", "Dia", "Mereka", "Kita", "Kami"]
    
    var videotips = videoTips()
    var videopreviewtips = videoPreviewTips()
    var selectwordstips = selectWordsTips()
    
    @AppStorage("completedPronounsRaw") private var completedPronounsRaw: String = ""
    private var completedWords: Set<String> {
        get { Set(completedPronounsRaw
            .split(separator: ",")
            .map { String($0) }
            .filter { !$0.isEmpty }) }
        set { completedPronounsRaw = newValue.sorted().joined(separator: ",") }
    }
    
    // Tinggi penuh kartu saat terbuka
    let fullCardHeight: CGFloat = 250
    
    // Seberapa banyak kartu yang terlihat saat tertutup (di bagian bawah layar)
    let peekHeight: CGFloat = 40
    
    // untuk menyimpan sekarang di kata yang mana melalui index array pronouns
    @State private var currentIndex: Int = 0
    
    // Function untuk mendapatkan URL video berdasarkan kata
    func getVideoURL(for word: String) -> URL? {
        let videoName = word.lowercased()
        return Bundle.main.url(forResource: videoName, withExtension: "mov")
    }
    
    // function untuk update kata yang dipilih setelah pencet next/previous
    func updateSelectedWord(to index: Int) {
        let boundedIndex = min(max(index, 0), pronouns.count - 1)
        currentIndex = boundedIndex
        selectedWord = pronouns[boundedIndex]
    }
    
    // Function untuk update index berdasarkan kata yang dipilih
    func updateCurrentIndex(for word: String) {
        if let index = pronouns.firstIndex(of: word) {
            currentIndex = index
        }
    }

    var body: some View {
        ZStack {
            // MARK: - Konten Utama Aplikasi
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
                .overlay(
                    ZStack{
                        VStack {
                            GeometryReader {
                                geometry in
                                HStack {
                                    Button(action: {
                                        onBack()
                                    }) {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                                .frame(width: 32, height: 48)
                                                .fontWeight(.bold)
                                            Text("Pilih Level")
                                                .font(.system(size: 20, weight: .semibold))
                                        }
                                        .padding(.trailing)
                                    }
                                    Spacer()
                                    Text(camera.lastPrediction)
                                        .font(.system(size: 24, weight: .bold))
                                        .padding(.trailing, 112)
                                    Spacer()
                                }
                                .frame(width: geometry.size.width, alignment: .leading)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top)
                                
                                HStack (alignment: .center, spacing: 24){
                                    ZStack {
                                        // Video berubah berdasarkan selectedWord
                                        if let selectedWord = selectedWord,
                                           let videoURL = getVideoURL(for: selectedWord) {
                                            VideoContainerView(videoURL: videoURL)
                                                .id(selectedWord) // Force refresh when word changes
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.9)
                                                .background(Color.red.opacity(0.2))
                                        } else {
                                            // Default video jika tidak ada yang dipilih
                                            VideoContainerView(videoURL: Bundle.main.url(forResource: "aku", withExtension: "mov")!)
                                                .id("aku") // Default ID
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.9)
                                                .background(Color.red.opacity(0.2))
                                        }

                                        VStack {
                                            HStack(spacing: 16) {
                                                Button(action: {
                                                    updateSelectedWord(to: currentIndex - 1)
                                                }) {
                                                    Image(systemName: "chevron.left.circle.fill")
                                                        .resizable()
                                                        .frame(width: 48, height: 48)
                                                        .foregroundColor(currentIndex > 0 ? .white : .gray)
                                                }
                                                .disabled(currentIndex == 0)
                                                .buttonStyle(PlainButtonStyle())

                                                Text(pronouns[currentIndex])
                                                    .frame(width: 100)
                                                    .font(.title)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Capsule())

                                                Button(action: {
                                                    updateSelectedWord(to: currentIndex + 1)
                                                }) {
                                                    Image(systemName: "chevron.right.circle.fill")
                                                        .resizable()
                                                        .frame(width: 48, height: 48)
                                                        .foregroundColor(currentIndex < pronouns.count - 1 ? .white : .gray)
                                                }
                                                .disabled(currentIndex == pronouns.count - 1)
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            .frame(width: geometry.size.width * 0.35, height: 80, alignment: .center)
                                            .background(Color.gray.opacity(0.5))
                                            Spacer()
                                        }

                                        TipView(videotips, arrowEdge: .top)
                                            .tipBackground(Color.black.opacity(0.6))
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.9)
                                    
                                    ZStack{
                                        CameraPreview(session: camera.session)
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                        TipView(videopreviewtips, arrowEdge: .top)
                                            .tipBackground(Color.black.opacity(0.6))
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(width: geometry.size.width * 0.635, height: geometry.size.height * 0.75)
                                }
                                .frame(height: geometry.size.height)
                                .padding(.top, 35)
                            }
                        }
                        .padding(8)
                    }
                )
                .onTapGesture {
                    if isCardOpen{
                        isCardOpen.toggle()
                    }
                }
            
            // MARK: - Komponen Pembuka Kartu
            VStack {
                Spacer()
                ZStack{
                CardView(
                    isCardOpen: $isCardOpen,
                    selectedWord: $selectedWord,
                    completedWords: completedWords,
                    pronouns: pronouns,
                    currentIndex: $currentIndex,
                    onWordSelected: { word in
                        // Update currentIndex ketika kata dipilih dari card
                        updateCurrentIndex(for: word)
                    }
                )
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25))
                .frame(height: fullCardHeight)
                .offset(y: isCardOpen ? 0 : fullCardHeight - peekHeight)
                .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: isCardOpen)
                    TipView(selectwordstips,arrowEdge: .bottom)
                        .padding(.bottom,-50)
                        .tipBackground(Color.black.opacity(0.6))
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            
            //MARK: Overlay cek bener apa engga
            if showOverlay {
                Color.black.opacity(0.4).ignoresSafeArea()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            camera.start()
            updateSelectedWord(to: 0)
        }
        //MARK: uncomment this on prod
        .task {
            // Configure and load your tips at app launch.
            do {
                try Tips.configure()
            }
            catch {
                // Handle TipKit errors
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
        .onChange(of: camera.lastPrediction) { newPrediction in
            guard let picked = selectedWord,
                  picked == newPrediction
            else { return }

            // ✅ Update completedWords jika belum ada
            var updated = completedWords
            if !updated.contains(picked) {
                updated.insert(picked)
                completedPronounsRaw = updated.sorted().joined(separator: ",")
            }

            // ✅ Tampilkan overlay (checkmark hijau)
            withAnimation {
                showOverlay = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showOverlay = false
                }
            }

            // ✅ Cek apakah semua pronouns sudah selesai
            let allPronouns = pronouns
            if allPronouns.allSatisfy({ updated.contains($0) }) {
                showCompletionModal = true
            }
        }

        .sheet(isPresented: $showCompletionModal) {
            VStack(spacing: 20) {
                Text("🎉 Kamu sudah membuka Training Ground!")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Ingin mencoba skill-mu?")
                    .font(.headline)

                HStack(spacing: 20) {
                    Button("Let's Go") {
                        // Navigasi ke halaman berikutnya
                        print("User chose to go!")
                        showCompletionModal = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Do it Later") {
                        showCompletionModal = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(width: 400, height: 300)
        }
    }
}

// MARK: - CardView (Tampilan Kartu Itu Sendiri)
struct CardView: View {
    @Binding var isCardOpen: Bool
    @Binding var selectedWord: String?
    let completedWords: Set<String>
    let pronouns: [String]
    @Binding var currentIndex: Int
    let onWordSelected: (String) -> Void

    var body: some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
            
            VStack {
                // MARK: Chevron untuk Animasi
                HStack {
                    Spacer()
                    Text(isCardOpen ? "Tutup" : "Ingin Belajar Kata Ganti Lain? Pilih Disini!")
                    Image(systemName: "chevron.up")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(isCardOpen ? 180 : 0))
                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: isCardOpen)
                    Spacer()
                }
                .frame(width: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.blue]), startPoint: .top, endPoint: .bottom))
                .onTapGesture {
                    isCardOpen.toggle()
                }
                
                Spacer()
                
                if isCardOpen {
                    Text("Pilih Kata Ganti")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        ForEach(pronouns, id: \.self) { word in
                            Button(action: {
                                // 1️⃣ record selection
                                selectedWord = word
                                // 2️⃣ Update current index
                                onWordSelected(word)
                                print("\(word) tapped")
                                isCardOpen.toggle()
                            }) {
                                HStack {
                                    Text(word)
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    
                                    VStack {
                                        if completedWords.contains(word) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.yellow)
                                        }
                                        
                                        if selectedWord == word {
                                            Image(systemName: "hand.point.up.left.fill")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                } else {
                    Spacer()
                    Text("Tekan Chevron untuk Membuka")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 1200)
    }
}
